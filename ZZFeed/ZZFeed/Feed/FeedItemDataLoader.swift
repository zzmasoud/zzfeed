//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public protocol FeedItemDataLoaderTask {
    func cancel()
}

public protocol FeedItemDataLoader {
    typealias LoadResult = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedItemDataLoaderTask
}
