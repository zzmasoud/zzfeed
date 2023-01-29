//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation


public final class LocalFeedLoader: FeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date
    
    public typealias LoadResut  = FeedLoader.Result

    public init(store: FeedStore, currentDate: @escaping ()->Date) {
        self.store = store
        self.currentDate = currentDate
    }
        
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

// MARK: - Save

extension LocalFeedLoader {
    public typealias SaveResult = Error?

    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self]  error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
            
    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard let _ = self else { return }
            completion(error)
        }
    }
}

// MARK: - Validation

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: {_ in completion(.success(())) })
                
            case let .success(.fetched(_, timestamp)) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: {_ in completion(.success(())) })
            
            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
    
    static var empty = [FeedItem]()
}

private extension Array where Element == LocalFeedItem {
    func toModels() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
