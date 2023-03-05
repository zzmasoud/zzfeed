//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var container: CustomLoadableView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var retryButton: UIButton!

    @IBAction private func retryTapped() {
        onRetry?()
    }

    var onRetry: (()->Void)?
    var onReuse: (() -> Void)?
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuse?()
    }
}
