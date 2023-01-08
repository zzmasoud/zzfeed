//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit

final class FeedItemCellController {
    
    private let viewModel: FeedItemViewModel<UIImage>
    
    init(viewModel: FeedItemViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedItemCell())
        viewModel.loadImageData()
        return cell
    }
    
    private func binded(_ cell: FeedItemCell) -> FeedItemCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingChange = { [weak cell] isLoading in
            cell?.container.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
}

