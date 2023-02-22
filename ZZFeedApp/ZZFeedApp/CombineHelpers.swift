//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import Combine
import ZZFeed

// MARK: - FeedItemDataLoader

public extension FeedItemDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedItemDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data {
    func caching(to cache: FeedItemDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

extension FeedItemDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        self.save(data: data, for: url, completion: { _ in })
    }
}


// MARK: - FeedLoader

public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedItem], Error>
    
    func loadPublisher() -> Publisher {
        return Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedItem] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult)
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> (AnyPublisher<Output, Failure>)) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

