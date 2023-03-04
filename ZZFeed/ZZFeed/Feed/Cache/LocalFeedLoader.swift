//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation


public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date

    public init(store: FeedStore, currentDate: @escaping ()->Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

// MARK: - Load

extension LocalFeedLoader {
    public typealias LoadResult = Swift.Result<[FeedImage], Error>

    public func load(completion: @escaping (LoadResult) -> Void) {
        completion(LoadResult {
            if let cachedFeed = try store.retrieve(),
               case let .fetched(feed, timestamp) = cachedFeed,
               FeedCachePolicy.validate(timestamp, against: currentDate()) {
                return feed.toModels()
            }
            return []
        })
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}

// MARK: - Save

extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal(), timestamp: currentDate())
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
    
    static var empty = [FeedImage]()
}

// MARK: - Validation

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: completion)
                
            case let .success(.fetched(_, timestamp)) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: { deletionResult in
                    completion(deletionResult)
                })
            
            case .success:
                completion(.success(()))
            }
        }
    }
}
