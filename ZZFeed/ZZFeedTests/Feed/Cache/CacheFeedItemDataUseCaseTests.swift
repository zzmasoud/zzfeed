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
        
        try? sut.save(data: data, for: url)

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
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        action()
        
        let receivedResult = Result { try sut.save(data: Data(), for: anyURL()) }
        
        switch (receivedResult, expectedResult) {
        case (.failure(let error as LocalFeedImageDataLoader.SaveError),
              .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
            XCTAssertEqual(error , expectedError, file: file, line: line)
            
        case (.success, .success):
            break
            
        default:
            XCTFail("expected to get \(expectedResult) but got \(receivedResult)", file: file, line: line)
        }
    }
}
