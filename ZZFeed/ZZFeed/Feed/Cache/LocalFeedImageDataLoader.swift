//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(data: Data, for url: URL, completion: @escaping(InsertionResult) -> Void)
}

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public typealias SaveResult = FeedImageDataCache.Result
    
    public enum SaveError: Swift.Error {
        case failed
    }

    public func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, for: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            completion(result.mapError { _ in SaveError.failed})
        })
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed, notFound
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadItemDataTask(completion: completion)
        store.retrieve(dataForURL: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data == nil ? .failure(LoadError.notFound) : .success(data!)
                }
            )
        })
        
        return task
    }
    
    private final class LoadItemDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.LoadResult) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
}