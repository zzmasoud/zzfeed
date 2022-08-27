//
//  LocalFeedLoader.swift
//  ZZFeed
//
//  Created by Masoud on 21/8/22.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: ()->Date
    
    public typealias SaveResult = Error?
    public typealias LoadResut  = FeedLoaderResult<Error>

    public init(store: FeedStore, currentDate: @escaping ()->Date) {
        self.store = store
        self.currentDate = currentDate
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
        store.retrieve { error in
            if let error = error {
                completion(.failure(error))
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
}
