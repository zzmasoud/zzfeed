//
//  ValidateFeedCacheUseCaseTests.swift
//  ZZFeedTests
//
//  Created by Masoud on 2/9/22.
//

import XCTest
import ZZFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
     
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()

        sut.validateCache()
        store.completeRetrieval(with: retrievalError)
  
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
  
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let lessThanSevenDays: Date = Calendar.current.date(byAdding: .day, value: -7, to: now)!.addingTimeInterval(1)
        let (sut, store) = makeSUT(currentDate: { now })
        
        sut.validateCache()
        store.completeRetrieval(with: items.local, timestamp: lessThanSevenDays)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let sevenDays: Date = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let (sut, store) = makeSUT(currentDate: { now })
        
        sut.validateCache()
        store.completeRetrieval(with: items.local, timestamp: sevenDays)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesMoreThanSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let moreThanSevenDays: Date = Calendar.current.date(byAdding: .day, value: -7, to: now)!.addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { now })
        
        sut.validateCache()
        store.completeRetrieval(with: items.local, timestamp: moreThanSevenDays)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }


    // - MARK: Helpers
    
    private func makeSUT(currentDate: @escaping ()->Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://foo.bar")!
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "description...", location: "-", imageURL: anyURL())
    }
    
    private func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let localItems = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
        return (items, localItems)
    }
}

private extension Date {
    func add(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -days, to: self)!
    }
}
