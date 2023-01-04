//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeed

final class FeedItemCellController {
    private var task: FeedItemDataLoaderTask?
    private let model: FeedItem
    private let imageLoader: FeedItemDataLoader
    
    init(model: FeedItem, imageLoader: FeedItemDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedItemCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        cell.container.isShimmering = true
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImageData(from: self.model.imageURL) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.retryButton.isHidden = (image != nil)
                cell?.container.isShimmering = false
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.imageURL) { _ in }
    }
    
    deinit {
        print("cancelling with url", model.imageURL)
        task?.cancel()
    }
}

