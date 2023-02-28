//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}
