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
}
