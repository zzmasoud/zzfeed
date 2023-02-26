//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import ZZFeed
import ZZFeediOS
import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedItemView where T: FeedItemView, T.Image == UIImage {
    func display(_ item: FeedItemViewModel<UIImage>) {
        object?.display(item)
    }
}
