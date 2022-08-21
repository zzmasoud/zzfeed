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
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequireCacheInsertionOnDeletionError() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let error = anyNSError()
        let (sut, store) = makeSUT()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: error)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let deletionError = anyNSError()
        let (sut, store) = makeSUT()
        
        var receivedError: Error?
        let exp = expectation(description: "waiting for completion...")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let insertionError = anyNSError()
        let (sut, store) = makeSUT()
        
        var receivedError: Error?
        let exp = expectation(description: "waiting for completion...")
        sut.save(items) { error in
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

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error) {
        deletionCompletions.first?(error)
    }
    
    func completeDeletionSuccessfully() {
        deletionCompletions.first?(nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error: Error) {
        insertionCompletions.first?(error)
    }
    
    func completeInsertionSuccessfully() {
        insertionCompletions.first?(nil)
    }
}
