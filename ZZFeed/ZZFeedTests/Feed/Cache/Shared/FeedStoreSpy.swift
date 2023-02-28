//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation
import ZZFeed

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error) {
        deletionCompletions.first?(.failure(error))
    }
    
    func completeDeletionSuccessfully() {
        deletionCompletions.first?(.success(()))
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error: Error) {
        insertionCompletions.first?(.failure(error))
    }
    
    func completeInsertionSuccessfully() {
        insertionCompletions.first?(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error) {
        retrievalCompletions.first?(.failure(error))
    }
    
    func completeRetrievalWithEmptyCache() {
        retrievalCompletions.first?(.success(.empty))
    }
    
    func completeRetrieval(with items: [LocalFeedImage], timestamp: Date) {
        retrievalCompletions.first?(.success(.fetched(items: items, timestamp: timestamp)))
        
    }
}

