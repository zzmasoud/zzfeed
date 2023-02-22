//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import Combine
import ZZFeed
import ZZFeediOS

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let dataLoader: (URL) -> FeedItemDataLoader.Publisher
    
    internal init(controller: FeedViewController, dataLoader: @escaping (URL) -> FeedItemDataLoader.Publisher) {
        self.controller = controller
        self.dataLoader = dataLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { item in
            let adapter = FeedItemDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedItemCellController>, UIImage>(model: item) { url in
                self.dataLoader(url)
            }
            
            let view = FeedItemCellController(delegate: adapter)
            adapter.presenter = FeedItemPresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        })
    }
}
