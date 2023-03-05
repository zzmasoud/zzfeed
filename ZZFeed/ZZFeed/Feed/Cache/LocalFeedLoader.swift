//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

// MARK: - Save

extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal(), timestamp: currentDate())
    }
}

// MARK: - Load

extension LocalFeedLoader {
    public func load() throws -> [FeedImage] {
        if let cache = try store.retrieve(),
           FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
            return cache.feed.toModels()
        }
        return []
    }
}

// MARK: - Validate

extension LocalFeedLoader {
    private struct InvalidCache: Error {}
    
    public func validateCache() throws {
        do {
            if let cache = try store.retrieve(),
               !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
        } catch {
            try store.deleteCachedFeed()
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
