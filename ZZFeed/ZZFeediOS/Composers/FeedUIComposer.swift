//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: MainQueueDispatchDecoder(decoratee: feedLoader))
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        let feedController = FeedViewController(refreshController: refreshController)
        feedController.title = NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedUIComposer.self), comment: "Title for the feed view")
        feedPresenter.feedLoadingView = refreshController
        feedPresenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        return feedController
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedItemDataLoader
    
    internal init(controller: FeedViewController, loader: FeedItemDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(feed: [FeedItem]) {
        controller?.models = feed.map {
            let viewModel = FeedItemViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)
            return FeedItemCellController(viewModel: viewModel)
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
