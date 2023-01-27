//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public protocol FeedItemDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
    func insert(data: Data, for url: URL, completion: @escaping(InsertionResult) -> Void)
}

public final class LocalFeedItemDataLoader: FeedItemDataLoader {
    public enum Error: Swift.Error {
        case failed, notFound
    }
    
    private let store: FeedItemDataStore
    
    public init(store: FeedItemDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) -> FeedItemDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    data == nil ? .failure(Error.notFound) : .success(data!)
                }
            )
        })
        
        return task
    }
    
    public func save(data: Data, for url: URL) {
        store.insert(data: data, for: url, completion: {_ in })
    }
    
    private final class Task: FeedItemDataLoaderTask {
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
