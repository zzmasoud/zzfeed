//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit
import ZZFeed
import ZZFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        let remoteImageLoader = RemoteFeedItemDataLoader(client: client)
        
        let feedStore = CodableFeedStore(storeURL: URL(string: "feedstore.code")!)
        let localFeedLoader = LocalFeedLoader(
            store: feedStore,
            currentDate: Date.init
        )
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: remoteFeedLoader,
                fallback: localFeedLoader),
            imageLoader: FeedItemDataLoaderWithFallbackComposite(
                primary: remoteImageLoader,
                fallback: remoteImageLoader))
        
        window?.rootViewController = feedViewController
    }
}
