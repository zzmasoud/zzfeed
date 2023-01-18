//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: MainQueueDispatchDecoder(decoratee: feedLoader))
        let feedRefreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: feedRefreshController)
        feedController.title = NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedUIComposer.self), comment: "Title for the feed view")
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

private final class MainQueueDispatchDecoder: FeedLoader {
    private let decoratee: FeedLoader
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
