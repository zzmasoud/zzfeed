//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import ZZFeed

public final class FeedItemDataLoaderCacheDecorator: FeedItemDataLoader {
    private let decoratee: FeedItemDataLoader
    private let cache: FeedItemDataCache
    
    public init(decoratee: FeedItemDataLoader, cache: FeedItemDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.LoadResult) -> Void) -> ZZFeed.FeedItemDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data: data, for: url, completion: { _ in })
                return data
            })
        }
    }
}
