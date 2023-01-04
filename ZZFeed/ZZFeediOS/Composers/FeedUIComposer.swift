//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemDataLoader) -> FeedViewController {
        let feedRefreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: feedRefreshController)
        feedRefreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedItemDataLoader) -> ([FeedItem]) -> Void {
        return { [weak controller] feed in
            controller?.models = feed.map {
                FeedItemCellController(model: $0, imageLoader: loader)
            }
        }
    }
}
