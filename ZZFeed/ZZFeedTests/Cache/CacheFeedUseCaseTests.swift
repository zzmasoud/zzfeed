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
    
    func deleteCachedFeed() {
        deletedCachedFeedCallCount += 1
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
    
    // - MARK: Helpers
    
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
        
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "description...", location: "-", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://foo.bar")!
    }

}
