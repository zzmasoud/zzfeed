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
        feedRefreshController.onRefresh = { [weak feedController] feed in
            feedController?.models = feed.map {
                FeedItemCellController(model: $0, imageLoader: imageLoader)
            }
        }
        return feedController
    }
}
