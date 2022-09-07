//
//  LocalFeedLoader.swift
//  ZZFeed
//
//  Created by Masoud on 21/8/22.
//

import Foundation

private final class FeedCachePolicy {
    
    private let currentDate: ()->Date
    private let calendar = Calendar.current
    
    init(currentDate: @escaping ()->Date) {
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }

    func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return currentDate() < maxCacheAge
    }
}

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date
    private let cachePolicy: FeedCachePolicy
    
    public typealias SaveResult = Error?
    public typealias LoadResut  = FeedLoaderResult<Error>

    public init(store: FeedStore, currentDate: @escaping ()->Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = FeedCachePolicy(currentDate: currentDate)
    }
    
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
    
    public func load(completion: @escaping (LoadResut) -> Void) {
        store.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .fetched(items, timestamp) where self.cachePolicy.validate(timestamp):
                completion(.success(items.toModels()))
                
            case .fetched, .empty:
                completion(.success(.empty))
            }
        }
    }
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: {_ in })
                
            case let .fetched(_, timestamp) where !self.cachePolicy.validate(timestamp):
                self.store.deleteCachedFeed(completion: {_ in })
            
            case .empty, .fetched:
                break
            }
        }
    }
        
    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard let _ = self else { return }
            completion(error)
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
