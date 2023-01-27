//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting to retrieve from cache....")
        sut.retrieve { retrieveResult in
            switch (retrieveResult, expectedResult) {
                
            case let (.success(.fetched(fetched)), .success(.fetched(expectedFetched))):
                XCTAssertEqual(fetched.timestamp, expectedFetched.timestamp, file: file, line: line)
                XCTAssertEqual(fetched.items, expectedFetched.items, file: file, line: line)
                
            case (.success(.empty), .success(.empty)), (.failure, .failure):
                break

            default:
                XCTFail("expected to get \(expectedResult) but got \(retrieveResult)!", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
    }
    
    func expect(sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetrieve: expectedResult)
        expect(sut: sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedItem], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
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
    func delete(from sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "waiting for deletion ...")
        var error: Error?
        sut.deleteCachedFeed { deletionError in
            error = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return error
    }
    
}
