//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit

protocol FeedItemCellControllerDelegate {
     func didRequestImage()
     func didCancelImageRequest()
 }

final class FeedItemCellController: FeedItemView {
    typealias Image = UIImage
    
    private let delegate: FeedItemCellControllerDelegate
    private var cell: FeedItemCell?
    
    init(delegate: FeedItemCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func display(_ viewModel: FeedItemViewModel<Image>) {
        cell?.feedImageView.image = viewModel.image
        cell?.container.isShimmering = viewModel.isLoading
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.retryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
