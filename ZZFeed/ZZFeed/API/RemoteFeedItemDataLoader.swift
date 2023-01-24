//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public final class RemoteFeedItemDataLoader {
    private let client: HttpClient
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public init(client: HttpClient) {
        self.client = client
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) -> FeedItemDataLoaderTask {
        let task = HttpClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return}
            
            switch result {
            case .failure(let error):
                task.complete(with: .failure(error))
                
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            }
        }
        
        return task
    }
    
    // MARK: - HttpClientTaskWrapper
    
    private final class HttpClientTaskWrapper: FeedItemDataLoaderTask {
        private var completion: ((FeedItemDataLoader.Result) -> Void)?
        var wrapped: HttpClientTask?
        
        init(_ completion: @escaping (FeedItemDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedItemDataLoader.Result) {
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
