//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedItem]
        let timestamp: Date
        
        var localFeed: [LocalFeedItem] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedItem: Codable {
        public let id: UUID
        public let imageURL: URL
        public let description: String?
        public let location: String?
        
        init(_ item: LocalFeedItem) {
            id = item.id
            imageURL = item.imageURL
            description = item.description
            location = item.location
        }
        
        var local: LocalFeedItem {
            return LocalFeedItem(id: id, description: description, location: location, imageURL: imageURL)
        }
    }
    
    private let queue: DispatchQueue = DispatchQueue(label: "zzfeed.\(CodableFeedStore.self).queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.empty))
            }
            
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Cache.self, from: data)
                completion(.success(.fetched(items: decoded.localFeed, timestamp: decoded.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedItem.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            if FileManager.default.fileExists(atPath: storeURL.path) {
                do {
                    try FileManager.default.removeItem(at: storeURL)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.success(()))
            }
        }
    }
}
