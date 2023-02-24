//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import ZZFeed
import UIKit

public struct FeedItemViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    var hasLocation: Bool { location != nil }
}
