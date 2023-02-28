//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import Combine
import ZZFeed
import ZZFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let dataLoader: (URL) -> FeedImageDataLoader.Publisher
    
    private typealias ItemDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    internal init(controller: FeedViewController, dataLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.dataLoader = dataLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = ItemDataPresentationAdapter(loader: { [dataLoader] in
                dataLoader(model.imageURL)
            })

            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)

            return view
        })
    }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
