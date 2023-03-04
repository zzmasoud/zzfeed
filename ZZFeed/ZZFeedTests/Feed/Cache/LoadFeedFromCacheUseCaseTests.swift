//
//  Copyright © zzmasoud (github.com/zzmasoud).
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
    
    func test_load_deliversCachedImagesOnNonExpiredCache() {
        let items = uniqueItems()
        let now = Date()
        let lessThanSevenDays: Date = now.minusFeedCacheMaxAge().addingTimeInterval(1)
        let (sut, store) = makeSUT(currentDate: { now })
        
        expect(sut, toCompleteWith: .success(items.models)) {
            store.completeRetrieval(with: items.local, timestamp: lessThanSevenDays)
        }
    }

    func test_load_deliversNoItemsOnCacheExpiration() {
        let now = Date()
        let sevenDays: Date = now.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { now })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: [], timestamp: sevenDays)
        }
    }
    
    func test_load_deliversNoItemsOnExpiredCache() {
        let now = Date()
        let sevenDays: Date = now.minusFeedCacheMaxAge() 
        let (sut, store) = makeSUT(currentDate: { now })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: [], timestamp: sevenDays)
        }
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        store.completeRetrieval(with: retrievalError)

        sut.load {_ in }
  
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()

        sut.load {_ in }
  
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnLessThanSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let lessThanSevenDays: Date = now.minusFeedCacheMaxAge().addingTimeInterval(1)
        let (sut, store) = makeSUT(currentDate: { now })
        store.completeRetrieval(with: items.local, timestamp: lessThanSevenDays)
        
        sut.load { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let sevenDays: Date = now.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { now })
        store.completeRetrieval(with: items.local, timestamp: sevenDays)
        
        sut.load { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnMoreThanSevenDaysOldCache() {
        let items = uniqueItems()
        let now = Date()
        let moreThanSevenDays: Date = now.minusFeedCacheMaxAge().addingTimeInterval(-1)
        let (sut, store) = makeSUT(currentDate: { now })
        store.completeRetrieval(with: items.local, timestamp: moreThanSevenDays)
        
        sut.load { _ in }

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
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        action()
        
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
        
        wait(for: [exp], timeout: 1)
    }
}
