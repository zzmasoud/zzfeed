//
//  FeedStore.swift
//  ZZFeed
//
//  Created by Masoud on 21/8/22.
//

import Foundation

public enum RetrievalCachedFeedResult {
    case empty
    case fetched(items: [LocalFeedItem], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalCachedFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let imageURL: URL
    public let description: String?
    public let location: String?
    
    public init(id: UUID = UUID(), description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.imageURL = imageURL
        self.description = description
        self.location = location
    }
}
