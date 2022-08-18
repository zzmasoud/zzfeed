//
//  CacheFeedUseCaseTests.swift
//  ZZFeedTests
//
//  Created by Masoud on 16/8/22.
//

import XCTest
import ZZFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deletedCachedFeedCallCount = 0
    var insertCallCount = 0
    
    func deleteCachedFeed() {
        deletedCachedFeedCallCount += 1
    }
    
    func completeDeletion(with error: Error) {
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deletedCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let (sut, store) = makeSUT()

        sut.save(items)
        XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequireCacheInsertionOnDeletionError() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let error = anyNSError()
        let (sut, store) = makeSUT()
        
        sut.save(items)
        store.completeDeletion(with: error)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
        
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "description...", location: "-", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://foo.bar")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

}
