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

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let localImageLoader = LocalFeedItemDataLoader(store: feedStore)
        
        let client = makeRemoteClient()
        let remoteImageLoader = RemoteFeedItemDataLoader(client: client)
        
        let feedViewController = FeedUIComposer
            .feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: FeedItemDataLoaderWithFallbackComposite(
                    primary: localImageLoader,
                    fallback: FeedItemDataLoaderCacheDecorator(
                        decoratee: remoteImageLoader,
                        cache: localImageLoader)))
        
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
