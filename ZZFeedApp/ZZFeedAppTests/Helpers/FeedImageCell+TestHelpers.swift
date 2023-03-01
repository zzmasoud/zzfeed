//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeediOS

extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingLoadingIndicator: Bool {
        return container.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !retryButton.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}

