//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedItemDataLoader) -> FeedViewController {
        let feedLoaderDispatch = MainQueueDispatchDecoder(decoratee: feedLoader)
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoaderDispatch)
        
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        feedController.title = NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedUIComposer.self), comment: "Title for the feed view")
        
        let imageLoaderDispatch = MainQueueDispatchDecoderDataLoader(decoratee: imageLoader)
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                loader: imageLoaderDispatch),
            feedLoadingView:
                WeakRefVirtualProxy(refreshController)
        )
        presentationAdapter.presenter = presenter
        
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
        controller?.models = viewModel.feed.map { item in
            let adapter = FeedItemDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedItemCellController>, UIImage>(
                model: item,
                imageLoader: loader)
            
            let view = FeedItemCellController(delegate: adapter)
            adapter.presenter = FeedItemPresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)

            case .failure(let error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class FeedItemDataLoaderPresentationAdapter<View: FeedItemView, Image>: FeedItemCellControllerDelegate where View.Image == Image {
     private let model: FeedItem
     private let imageLoader: FeedItemDataLoader
     private var task: FeedItemDataLoaderTask?

     var presenter: FeedItemPresenter<View, Image>?

     init(model: FeedItem, imageLoader: FeedItemDataLoader) {
         self.model = model
         self.imageLoader = imageLoader
     }

     func didRequestImage() {
         presenter?.didStartLoadingImageData(for: model)

         let model = self.model
         task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
             switch result {
             case let .success(data):
                 self?.presenter?.didFinishLoadingImageData(with: data, for: model)

             case let .failure(error):
                 self?.presenter?.didFinishLoadingImageData(with: error, for: model)
             }
         }
     }

     func didCancelImageRequest() {
         task?.cancel()
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

extension WeakRefVirtualProxy: FeedItemView where T: FeedItemView, T.Image == UIImage {
    func display(_ item: FeedItemViewModel<UIImage>) {
        object?.display(item)
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

private final class MainQueueDispatchDecoderDataLoader: FeedItemDataLoader {
    private let decoratee: FeedItemDataLoader
    
    init(decoratee: FeedItemDataLoader) {
        self.decoratee = decoratee
    }

    func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedItemDataLoaderTask {
        decoratee.loadImageData(from: url) { result in
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
