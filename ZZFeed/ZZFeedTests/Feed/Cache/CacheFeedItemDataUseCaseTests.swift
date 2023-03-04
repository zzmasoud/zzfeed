//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class CacheFeedItemDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = Data()
        let url = anyURL()
        
        sut.save(data: data, for: url, completion: {_ in })

        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageDataForURL_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.SaveError.failed)) {
            store.completeInsertion(with: anyNSError())
        }
    }
    
    func test_saveImageDataForURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(())) {
            store.completeInsertionSuccessfully()
        }
    }
        
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedItemDataStoreSpy) {
        let store = FeedItemDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion...")
        
        action()

        sut.save(data: Data(), for: anyURL(), completion: { result in
            switch (result, expectedResult) {
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as! LocalFeedImageDataLoader.SaveError , expectedError as! LocalFeedImageDataLoader.SaveError, file: file, line: line)
                
            case (.success, .success):
                break
                
            default:
                XCTFail("expected to get \(expectedResult) but got \(result)", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1)
    }
}
