//
//  LoadFeedFromCacheUseCaseTests.swift
//  ZZFeedTests
//
//  Created by Masoud on 25/8/22.
//

import XCTest
import ZZFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([]) ) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedItemsOnLessThanSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let lessThanSevenDays: Date = Calendar.current.date(byAdding: .day, value: -7, to: now)!.addingTimeInterval(1)
        let (sut, store) = makeSUT(currentDate: { now })
        expect(sut, toCompleteWith: .success(items.models)) {
            store.completeRetrieval(with: items.local, timestamp: lessThanSevenDays)
        }
    }

    func test_load_deliversCachedItemsOnSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let sevenDays: Date = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let (sut, store) = makeSUT(currentDate: { now })
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: items.local, timestamp: sevenDays)
        }
    }

    func test_load_deliversCachedItemsOnMoreThanSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let moreThanSevenDays: Date = Calendar.current.date(byAdding: .day, value: -7, to: now)!.addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { now })
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: items.local, timestamp: moreThanSevenDays)
        }
    }
    
    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()

        sut.load {_ in }
        store.completeRetrieval(with: retrievalError)
  
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    
    // - MARK: Helpers
    
    private func makeSUT(currentDate: @escaping ()->Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResut, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion...")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
                
            default:
                XCTFail("expected: \(expectedResult) but got: \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "description...", location: "-", imageURL: anyURL())
    }
    
    private func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let localItems = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
        return (items, localItems)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://foo.bar")!
    }
}
