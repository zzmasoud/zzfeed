//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public protocol FeedItemDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(data: Data, for url: URL, completion: @escaping(InsertionResult) -> Void)
}

public final class LocalFeedItemDataLoader {
    private let store: FeedItemDataStore
    
    public init(store: FeedItemDataStore) {
        self.store = store
    }
}

extension LocalFeedItemDataLoader {
    public func save(data: Data, for url: URL) {
        store.insert(data: data, for: url, completion: {_ in })
    }
}

extension LocalFeedItemDataLoader: FeedItemDataLoader {
    public enum LoadError: Swift.Error {
        case failed, notFound
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) -> FeedItemDataLoaderTask {
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
    
    private final class LoadItemDataTask: FeedItemDataLoaderTask {
        private var completion: ((FeedItemDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedItemDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedItemDataLoader.Result) {
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
