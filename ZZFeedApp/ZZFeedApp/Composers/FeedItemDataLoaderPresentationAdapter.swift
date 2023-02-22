//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import Combine
import ZZFeed
import ZZFeediOS

final class FeedItemDataLoaderPresentationAdapter<View: FeedItemView, Image>: FeedItemCellControllerDelegate where View.Image == Image {
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
