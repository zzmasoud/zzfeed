//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public final class RemoteFeedItemDataLoader: FeedItemDataLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.LoadResult) -> Void) -> FeedItemDataLoaderTask {
        let task = HttpClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return}
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
        }
        
        return task
    }
    
    // MARK: - HttpClientTaskWrapper
    
    private final class HttpClientTaskWrapper: FeedItemDataLoaderTask {
        private var completion: ((FeedItemDataLoader.LoadResult) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (FeedItemDataLoader.LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedItemDataLoader.LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
}
