//
//  FeedItemViewModel.swift
//  ZZFeediOS
//
//  Created by Masoud on 08.01.23.
//

import ZZFeed
import UIKit

final class FeedItemViewModel {
    typealias Observer<T> = (T)->Void
    
    private var task: FeedItemDataLoaderTask?
    private let model: FeedItem
    private let imageLoader: FeedItemDataLoader
    
    init(model: FeedItem, imageLoader: FeedItemDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var description: String? { model.description }
    var location: String? { model.location }
    var hasLocation: Bool { model.location != nil }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingChange: Observer<Bool>?
    var onShouldRetryImageLoadChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingChange?(true)
        onShouldRetryImageLoadChange?(false)
        task = imageLoader.loadImageData(from: self.model.imageURL) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedItemDataLoader.Result) {
        if let data = try? result.get(), let image = UIImage.init(data: data) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadChange?(true)
        }
        onImageLoadingChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
    }
}
