//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit
import ZZFeed
import ZZFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let storeURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed.sqlite")
        let feedStore = try! CoreDataFeedStore(storeURL: storeURL)
        let localFeedLoader = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        let localImageLoader = LocalFeedItemDataLoader(store: feedStore)
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: storeURL)
        }
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let client = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        let remoteImageLoader = RemoteFeedItemDataLoader(client: client)
        
        let feedViewController = FeedUIComposer
            .feedComposedWith(
                feedLoader: FeedLoaderWithFallbackComposite(
                    primary: FeedLoaderCacheDecorator(
                        decoratee: remoteFeedLoader,
                        cache: localFeedLoader),
                    fallback: localFeedLoader),
                imageLoader: FeedItemDataLoaderWithFallbackComposite(
                    primary: localImageLoader,
                    fallback: FeedItemDataLoaderCacheDecorator(
                        decoratee: remoteImageLoader,
                        cache: localImageLoader)))
        
        window?.rootViewController = feedViewController
    }
    
    private func makeRemoteClient() -> HttpClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {
        case "offline":
            return AlwaysFailingHTTPClient()
            
        default:
            let session = URLSession(configuration: .ephemeral)
            return URLSessionHTTPClient(session: session)
        }
    }
}

private final class AlwaysFailingHTTPClient: HttpClient {
    private class Task: HttpClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        completion(.failure(NSError(domain: "no connectivity", code: -1)))
        return Task()
    }
}
