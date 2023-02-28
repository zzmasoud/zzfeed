//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation


public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result)->Void)
}
