//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public struct FeedViewModel {
    public let feed: [FeedItem]
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}
