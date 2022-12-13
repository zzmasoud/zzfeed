//
//  CodableFeedStoreTests.swift
//  ZZFeedTests
//
//  Created by Masoud on 12/4/22.
//

import XCTest
import ZZFeed

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
        
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFetchedValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toRetrieve: .fetched(items: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueItems().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toRetrieveTwice: .fetched(items: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = storeURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = storeURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let feed = uniqueItems().local
        let insertionError = insert((feed, Date()), to: sut)
        XCTAssertNil(insertionError, "expected to get no error for insertion.")
        
        let latestFeed = uniqueItems().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(insertionError, "expected to get no error for the latest insertion.")
        
        expect(sut: sut, toRetrieve: .fetched(items: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid-ur-l")!
        let sut = makeSUT(storeURL: invalidURL)
        let feed = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "expected to get error due to invalid storeURL.")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError, "expected to get no error after deletion.")
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_clearsPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueItems().local, Date()), to: sut)
        
        let deletionError = delete(from: sut)
        
        XCTAssertNil(deletionError, "expected to get no error after deletion.")
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let storeURL = FileManager.default.homeDirectoryForCurrentUser
        let sut = makeSUT(storeURL: storeURL)
        
        let deletionError = delete(from: sut)
        
        XCTAssertNotNil(deletionError, "expected to get error after deletion.")
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var operations = [XCTestExpectation]()
        
        let op1 = expectation(description: "op1")
        sut.insert(uniqueItems().local, timestamp: Date(), completion: { _ in
            operations.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "op2")
        sut.deleteCachedFeed(completion: { _ in
            operations.append(op2)
            op2.fulfill()
        })
        
        let op3 = expectation(description: "op3")
        sut.insert(uniqueItems().local, timestamp: Date(), completion: { _ in
            operations.append(op3)
            op3.fulfill()
        })
        
        waitForExpectations(timeout: 3)
        
        XCTAssertEqual(operations, [op1, op2, op3], "expected to have operations serially and in order from 1 to 3")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL url: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: url ?? storeURL())
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(sut: FeedStore, toRetrieve expectedResult: RetrievalCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting to retrieve from cache....")
        sut.retrieve { retrieveResult in
            switch (retrieveResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.fetched(fetched), .fetched(expectedFetched)):
                XCTAssertEqual(fetched.timestamp, expectedFetched.timestamp, file: file, line: line)
                XCTAssertEqual(fetched.items, expectedFetched.items, file: file, line: line)
                
                
            default:
                XCTFail("expected to get \(expectedResult) but got \(retrieveResult)!", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)

    }
    
    private func expect(sut: FeedStore, toRetrieveTwice expectedResult: RetrievalCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetrieve: expectedResult)
        expect(sut: sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedItem], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "waiting for insertion ...")
        var error: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return error
    }

    @discardableResult
    private func delete(from sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "waiting for deletion ...")
        var error: Error?
        sut.deleteCachedFeed { deletionError in
            error = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return error
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: storeURL())
    }
}
