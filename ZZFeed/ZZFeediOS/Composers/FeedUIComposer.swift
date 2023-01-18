//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let feedRefreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: feedRefreshController)
        feedController.title = "My Feed"
        feedViewModel.onLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedItemDataLoader) -> ([FeedItem]) -> Void {
        return { [weak controller] feed in
            controller?.models = feed.map {
                let viewModel = FeedItemViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)
                return FeedItemCellController(viewModel: viewModel)
            }
        }
    }
}
