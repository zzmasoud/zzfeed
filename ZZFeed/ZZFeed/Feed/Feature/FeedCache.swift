//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedItem], completion: @escaping (Result) -> Void)
}
