//
//  Copyright © zzmasoud (github.com/zzmasoud).
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
        store.completeRetrieval(with: retrievalError)

        try? sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()

        try? sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let lessThanSevenDays: Date = now.minusFeedCacheMaxAge().addingTimeInterval(1)
        let (sut, store) = makeSUT(currentDate: { now })
        store.completeRetrieval(with: items.local, timestamp: lessThanSevenDays)
        
        try? sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let sevenDays: Date = now.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { now })
        store.completeRetrieval(with: items.local, timestamp: sevenDays)
        
        try? sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesMoreThanSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let moreThanSevenDays: Date = now.minusFeedCacheMaxAge().addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { now })
        store.completeRetrieval(with: items.local, timestamp: moreThanSevenDays)
        
        try? sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let deletionError = anyNSError()
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .failure(deletionError)) {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletionSuccessfully()
        }
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().addingTimeInterval(1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate})
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError)) {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let feed = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletionSuccessfully()
        }
    }

    // - MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()

        let receivedResult = Result { try sut.validateCache() }
        
        switch (receivedResult, expectedResult) {
        case (.success, .success):
            break
            
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}
