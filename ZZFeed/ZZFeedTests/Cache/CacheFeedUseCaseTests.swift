//
//  CacheFeedUseCaseTests.swift
//  ZZFeedTests
//
//  Created by Masoud on 16/8/22.
//

import XCTest
import ZZFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(uniqueItems().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequireCacheInsertionOnDeletionError() {
        let error = anyNSError()
        let (sut, store) = makeSUT()
        
        sut.save(uniqueItems().models) { _ in }
        store.completeDeletion(with: error)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = uniqueItems()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let deletionError = anyNSError()
        let (sut, store) = makeSUT()
        
        var receivedError: Error?
        let exp = expectation(description: "waiting for completion...")
        sut.save(uniqueItems().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        let insertionError = anyNSError()
        let (sut, store) = makeSUT()
        
        var receivedError: Error?
        let exp = expectation(description: "waiting for completion...")
        sut.save(uniqueItems().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let (sut, store) = makeSUT()
        
        var receivedError: Error?
        let exp = expectation(description: "waiting for completion...")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1)
        
        XCTAssertNil(receivedError)
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTHasbeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueFeedItem()], completion: { error in
            receivedErrors.append(error)
        })
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTHasbeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueFeedItem()], completion: { error in
            receivedErrors.append(error)
        })
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(currentDate: @escaping ()->Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
        
    }    
}
