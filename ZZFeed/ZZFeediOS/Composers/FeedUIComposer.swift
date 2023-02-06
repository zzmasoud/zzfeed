//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemDataLoader) -> FeedViewController {
        let feedLoaderDispatch = MainQueueDispatchDecoder(decoratee: feedLoader)
        let feedPresenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoaderDispatch, presenter: feedPresenter)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        feedController.title = NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedUIComposer.self), comment: "Title for the feed view")
        feedPresenter.feedLoadingView = WeakRefVirtualProxy(refreshController)
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
    
    func display(_ viewModel: FeedViewModel) {
        controller?.models = viewModel.feed.map {
            let viewModel = FeedItemViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)
            return FeedItemCellController(viewModel: viewModel)
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter.didFinishLoadingFeed(with: feed)

            case .failure(let error):
                self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
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
