//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeed
import ZZFeediOS
import Combine

private class ErrorView: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        return self.receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        private func isMainQueue() -> Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
        
        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }
        
        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: @escaping (URL) -> FeedItemDataLoader.Publisher) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: { feedLoader().dispatchOnMainQueue() })

        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                dataLoader: { imageLoader($0).dispatchOnMainQueue() }),
            loadingView:
                WeakRefVirtualProxy(feedController), errorView: ErrorView()
        )
        presentationAdapter.presenter = presenter
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = FeedPresenter.title
        return feedController
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let dataLoader: (URL) -> FeedItemDataLoader.Publisher
    
    internal init(controller: FeedViewController, dataLoader: @escaping (URL) -> FeedItemDataLoader.Publisher) {
        self.controller = controller
        self.dataLoader = dataLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.models = viewModel.feed.map { item in
            let adapter = FeedItemDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedItemCellController>, UIImage>(model: item) { url in
                self.dataLoader(url)
            }
            
            let view = FeedItemCellController(delegate: adapter)
            adapter.presenter = FeedItemPresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader().sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(with: feed)
        }

    }
}

private final class FeedItemDataLoaderPresentationAdapter<View: FeedItemView, Image>: FeedItemCellControllerDelegate where View.Image == Image {
    private let model: FeedItem
    private let imageLoader: (URL) -> FeedItemDataLoader.Publisher
    private var cancellable: Cancellable?

    var presenter: FeedItemPresenter<View, Image>?

     init(model: FeedItem, imageLoader: @escaping (URL) -> FeedItemDataLoader.Publisher) {
         self.model = model
         self.imageLoader = imageLoader
     }

     func didRequestImage() {
         presenter?.didStartLoadingImageData(for: model)

         let model = self.model
         
         cancellable = imageLoader(model.imageURL).sink { [weak self] completion in
             if case let .failure(error) = completion {
                 self?.presenter?.didFinishLoadingImageData(with: error, for: model)
             }
         } receiveValue: { [weak self] data in
             self?.presenter?.didFinishLoadingImageData(with: data, for: model)
         }
     }

     func didCancelImageRequest() {
         cancellable?.cancel()
     }
 }

