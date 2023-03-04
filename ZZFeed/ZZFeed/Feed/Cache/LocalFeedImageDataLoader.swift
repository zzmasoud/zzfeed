//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func insert(data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
    
    @available(*, deprecated)
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    
    @available(*, deprecated)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}

public extension FeedImageDataStore {
    func insert(data: Data, for url: URL) throws {
        let group = DispatchGroup()
        group.enter()
        var result: InsertionResult!
        insert(data: data, for: url) { res in
            result = res
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrievalResult!
        retrieve(dataForURL: url) {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {}
}

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Swift.Error {
        case failed
    }

    public func save(data: Data, for url: URL) throws {
        do {
            try store.insert(data: data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed, notFound
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadItemDataTask(completion: completion)
        task.complete(
            with: Swift.Result {
                try store.retrieve(dataForURL: url)
            }
            .mapError { _ in LoadError.failed }
            .flatMap { data in
                data.map { .success($0) } ?? .failure(LoadError.notFound)
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
