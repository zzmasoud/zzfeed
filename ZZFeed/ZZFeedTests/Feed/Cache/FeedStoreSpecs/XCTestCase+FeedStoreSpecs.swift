//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

extension FeedStoreSpecs where Self: XCTestCase {
     func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         expect(sut, toRetrieve: .success(.none), file: file, line: line)
     }

     func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
     }

     func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let feed = uniqueItems().local
         let timestamp = Date()

         insert((feed, timestamp), to: sut)

         expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
     }

     func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let feed = uniqueItems().local
         let timestamp = Date()

         insert((feed, timestamp), to: sut)

         expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)))
     }

     func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let insertionError = insert((uniqueItems().local, Date()), to: sut)

         XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
     }

     func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueItems().local, Date()), to: sut)

         let insertionError = insert((uniqueItems().local, Date()), to: sut)

         XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
     }

     func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueItems().local, Date()), to: sut)

         let latestFeed = uniqueItems().local
         let latestTimestamp = Date()
         insert((latestFeed, latestTimestamp), to: sut)

         expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
     }

     func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         let deletionError = delete(from: sut)

         XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
     }

     func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         delete(from: sut)

         expect(sut, toRetrieve: .success(.none), file: file, line: line)
     }

     func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueItems().local, Date()), to: sut)

         let deletionError = delete(from: sut)

         XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
     }

     func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
         insert((uniqueItems().local, Date()), to: sut)

         delete(from: sut)

         expect(sut, toRetrieve: .success(.none), file: file, line: line)
     }
 }

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let retrievedResult = Result { try sut.retrieve() }
        
        switch (expectedResult, retrievedResult) {
        case (.success(.none), .success(.none)),
             (.failure, .failure):
            break
            
        case let (.success(.some(expected)), .success(.some(retrieved))):
            XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
            XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
            
        default:
            XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
        }
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        do {
            try sut.insert(cache.feed, timestamp: cache.timestamp)
            return nil
        } catch {
            return error
        }
    }
    
    @discardableResult
    func delete(from sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        do {
            try sut.deleteCachedFeed()
            return nil
        } catch {
            return error
        }
    }
}
