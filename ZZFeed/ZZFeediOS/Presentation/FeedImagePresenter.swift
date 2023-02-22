//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import ZZFeed
import UIKit

public protocol FeedItemView {
    associatedtype Image
    
    func display(_ item: FeedItemViewModel<Image>)
}

public final class FeedItemPresenter<View: FeedItemView, Image> where View.Image == Image {
    private struct InvalidImageDataError: Error {}

    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedItem) {
        view.display(FeedItemViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedItem) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedItemViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedItem) {
        view.display(FeedItemViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
