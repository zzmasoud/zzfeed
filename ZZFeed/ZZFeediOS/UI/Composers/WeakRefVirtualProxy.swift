//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import ZZFeed
import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
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
