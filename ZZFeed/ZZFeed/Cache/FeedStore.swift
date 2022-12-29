//
//  FeedStore.swift
//  ZZFeed
//
//  Created by Masoud on 21/8/22.
//

import Foundation

    
public enum CachedFeed {
    case empty
    case fetched(items: [LocalFeedItem], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CachedFeed, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
