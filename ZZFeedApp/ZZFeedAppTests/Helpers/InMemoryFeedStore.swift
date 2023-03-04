//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import ZZFeed

class InMemoryFeedStore {
    private(set) var feedCache: CachedFeed?
    private var feedImageDataLoader: [URL: Data] = [:]
    
    private init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
}

extension InMemoryFeedStore: FeedStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        if let feedCache = feedCache {
            completion(.success(feedCache))
        } else {
            completion(.failure(NSError(domain: "error", code: -1)))
        }
    }

    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        feedCache = CachedFeed.fetched(items: items, timestamp: timestamp)
        completion(.success(()))
    }
}

extension InMemoryFeedStore: FeedImageDataStore {
    func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataLoader[url]
    }
    
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataLoader[url] = data
    }
}

extension InMemoryFeedStore {
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: .fetched(items: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: .fetched(items: [], timestamp: Date()))
    }
}
