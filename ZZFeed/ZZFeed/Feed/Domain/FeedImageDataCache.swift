//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
