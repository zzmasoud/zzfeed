//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZFeed

protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedItem], completion: @escaping (Result) -> Void)
}

class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            let feed = (try? result.get()) ?? []
            self?.cache.save(feed, completion: { _ in })
            completion(result)
        }
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = makeSUT(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let loader = FeedLoaderStub(result: .failure(anyNSError()))
        let sut = makeSUT(decoratee: loader)
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachedLoadedFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let cache = CacheSpy()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = makeSUT(decoratee: loader, cache: cache)

        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(decoratee: FeedLoader, cache: FeedCache = CacheSpy(), file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let sut = FeedLoaderCacheDecorator(decoratee: decoratee, cache: cache)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        enum Message: Equatable {
            case save(_ feed: [FeedItem])
        }
        
        private(set) var messages = [Message]()
        
        func save(_ feed: [FeedItem], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
