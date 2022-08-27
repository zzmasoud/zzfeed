//
//  FeedStoreSpy.swift
//  ZZFeedTests
//
//  Created by Masoud on 27/8/22.
//

import Foundation
import ZZFeed

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedItem], Date)
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
        deletionCompletions.first?(error)
    }
    
    func completeDeletionSuccessfully() {
        deletionCompletions.first?(nil)
    }
    
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error: Error) {
        insertionCompletions.first?(error)
    }
    
    func completeInsertionSuccessfully() {
        insertionCompletions.first?(nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error) {
        retrievalCompletions.first?(error)
    }
    
    func completeRetrievalWithEmptyCache() {
        retrievalCompletions.first?(nil)
    }
}

