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
    private lazy var feedStore: FeedStore & FeedItemDataStore = {
        return try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed.sqlite"))
    }()
    private lazy var localFeedLoader = LocalFeedLoader(store: feedStore, currentDate: Date.init)
    
    let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    private lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        return URLSessionHTTPClient(session: session)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedItemDataStore) {
        self.init()
        self.httpClient = httpClient
        self.feedStore = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        configureWindow()
    }
    
    func configureWindow() {
        let feedViewController = FeedUIComposer
            .feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalItemDataLoaderWithRemoteFallback)
        
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache(completion: { _ in })
    }
    
    func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    func makeLocalItemDataLoaderWithRemoteFallback(url: URL) -> FeedItemDataLoader.Publisher {
        let localItemDataLoader = LocalFeedItemDataLoader(store: feedStore)
        return localItemDataLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedItemDataMapper.map)
                    .caching(to: localItemDataLoader, using: url)
            })
    }
}
