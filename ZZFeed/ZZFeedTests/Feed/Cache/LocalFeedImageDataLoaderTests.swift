//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed


class LoadFeedItemDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponRequest() {
        let (_ , store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoreDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url, completion: {_ in })
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataForURL: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed()) {
            let retrievalError = anyNSError()
            store.complete(with: retrievalError)
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.complete(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversDataOnStoreFindsData() {
        let (sut, store) = makeSUT()
        let data = Data()
        
        expect(sut, toCompleteWith: found(data)) {
            store.complete(with: data)
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
    
    private func failed() -> FeedImageDataLoader.LoadResult {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.LoadResult {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func found(_ data: Data) -> FeedImageDataLoader.LoadResult {
        return .success(data)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion...")
        
        action()

        _ = sut.loadImageData(from: anyURL(), completion: { result in
            switch (result, expectedResult) {
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as! LocalFeedImageDataLoader.LoadError , expectedError as! LocalFeedImageDataLoader.LoadError, file: file, line: line)
                
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData)
                
            default:
                XCTFail("expected to get \(expectedResult) but got \(result)", file: file, line: line)
            }
            
            exp.fulfill()
        })
                
        wait(for: [exp], timeout: 1)
    }
}
