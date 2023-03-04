//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public protocol FeedImageDataCache {
    func save(data: Data, for url: URL) throws
}
