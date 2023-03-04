//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import CoreData

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        performAsync { context in
            do {
               let data = try ManagedFeedItem.data(with: url, in: context)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        performAsync { context in
            do {
                try ManagedFeedItem.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
