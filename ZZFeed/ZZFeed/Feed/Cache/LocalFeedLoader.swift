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

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResut  = FeedLoader.Result

    public func load(completion: @escaping (LoadResut) -> Void) {
        store.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(.fetched(items, timestamp)) where FeedCachePolicy.validate(timestamp, against: currentDate()):
                completion(.success(items.toModels()))
                
            case .success:
                completion(.success(.empty))
            }
        }
    }
}

private extension Array where Element == LocalFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}

// MARK: - Save

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = FeedCache.Result

    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self]  result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case .success:
                self.cache(items, with: completion)

            }
        }
    }
            
    private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] result in
            guard let _ = self else { return }
            completion(result)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
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
