//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public final class FeedItemCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let container = CustomLoadableView()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var retryButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return btn
    }()
    
    var onRetry: (()->Void)?
    
    @objc private func retryTapped() {
        onRetry?()
    }
}

public final class CustomLoadableView: UIView {
    public var isShimmering = false
}
