//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import ZZFeed

public final class FeedItemDataLoaderWithFallbackComposite: FeedItemDataLoader {
    private let primary: FeedItemDataLoader
    private let fallback: FeedItemDataLoader
    
    public init(primary: FeedItemDataLoader, fallback: FeedItemDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedItemDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url, completion: { [weak self] result in
            if let data = try? result.get() {
                completion(.success(data))
            } else {
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        })
        return task
    }
    
    private class TaskWrapper: FeedItemDataLoaderTask {
        var wrapped: FeedItemDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
}
