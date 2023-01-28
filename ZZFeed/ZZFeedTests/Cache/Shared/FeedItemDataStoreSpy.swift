//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation
import ZZFeed

class FeedItemDataStoreSpy: FeedItemDataStore {
    enum Message: Equatable {
        case retrieve(dataForURL: URL)
        case insert(data: Data, for: URL)
    }
    
    private var completions = [(FeedItemDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(FeedItemDataStore.InsertionResult) -> Void]()
    private(set) var receivedMessages = [Message]()
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedItemDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataForURL: url))
        completions.append(completion)
    }
    
    func complete(with error: NSError, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func complete(with data: Data?, at index: Int = 0) {
        completions[index](.success(data))
    }
    
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
}
