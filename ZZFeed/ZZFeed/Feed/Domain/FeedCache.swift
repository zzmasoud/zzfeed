//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
