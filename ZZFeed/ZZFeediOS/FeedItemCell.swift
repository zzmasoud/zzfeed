//
//  FeedItemCell.swift
//  ZZFeediOS
//
//  Created by zzmasoud on 1/1/23.
//

import UIKit

public final class FeedItemCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let container = CustomLoadableView()
}

public final class CustomLoadableView: UIView {
    public var isShimmering = false
}
