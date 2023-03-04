//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation
import ZZFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(dataForURL: URL)
        case insert(data: Data, for: URL)
    }
    
    private var retrievalResult: FeedImageDataStore.RetrievalResult?
    private var insertionResult: FeedImageDataStore.InsertionResult?
    private(set) var receivedMessages = [Message]()
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(dataForURL: url))
        return try retrievalResult?.get()
    }
    
    func complete(with error: NSError, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func complete(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }
    
    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}
