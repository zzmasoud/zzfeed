//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit
import ZZFeed
import ZZFeediOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let storeURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed.sqlite")
    private lazy var feedStore = try! CoreDataFeedStore(storeURL: storeURL)
    private lazy var localFeedLoader = LocalFeedLoader(store: feedStore, currentDate: Date.init)
    private lazy var httpClient = makeRemoteClient()

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let feedViewController = FeedUIComposer
            .feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalItemDataLoaderWithRemoteFallback)
        
        window?.rootViewController = feedViewController
    }
    
    func makeRemoteClient() -> HttpClient {
        let session = URLSession(configuration: .ephemeral)
        return URLSessionHTTPClient(session: session)
    }
    
    func makeRemoteFeedLoaderWithLocalFallback() -> RemoteFeedLoader.Publisher {
        let  url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let client = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    func makeLocalItemDataLoaderWithRemoteFallback(url: URL) -> FeedItemDataLoader.Publisher {
        let remoteItemDataLoader = RemoteFeedItemDataLoader(client: httpClient)
        let localItemDataLoader = LocalFeedItemDataLoader(store: feedStore)
        return localItemDataLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteItemDataLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localItemDataLoader, using: url)
            })
    }
}

public extension FeedItemDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedItemDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data {
    func caching(to cache: FeedItemDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

extension FeedItemDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        self.save(data: data, for: url, completion: { _ in })
    }
}


public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedItem], Error>
    
    func loadPublisher() -> Publisher {
        return Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedItem] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult)
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> (AnyPublisher<Output, Failure>)) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}
