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
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let data = Data()
        
        var capturedResults = [FeedItemDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL(), completion: { capturedResults.append($0)} )
        task.cancel()
        
        store.complete(with: .none)
        store.complete(with: anyNSError())
        store.complete(with: data)

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceIsDeallocated() {
        let store = FeedItemDataStoreSpy()
        var sut: LocalFeedItemDataLoader? = LocalFeedItemDataLoader(store: store)
        
        var capturedResults = [FeedItemDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL(), completion: { capturedResults.append($0)} )
        
        sut = nil
        
        store.complete(with: .none)

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedItemDataLoader, store: FeedItemDataStoreSpy) {
        let store = FeedItemDataStoreSpy()
        let sut = LocalFeedItemDataLoader(store: store)

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, store)
    }
    
    private func failed() -> FeedItemDataLoader.Result {
        return .failure(LocalFeedItemDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedItemDataLoader.Result {
        return .failure(LocalFeedItemDataLoader.LoadError.notFound)
    }
    
    private func found(_ data: Data) -> FeedItemDataLoader.Result {
        return .success(data)
    }
    
    private func expect(_ sut: LocalFeedItemDataLoader, toCompleteWith expectedResult: LocalFeedItemDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion...")
        _ = sut.loadImageData(from: anyURL(), completion: { result in
            switch (result, expectedResult) {
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as! LocalFeedItemDataLoader.LoadError , expectedError as! LocalFeedItemDataLoader.LoadError, file: file, line: line)
                
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData)
                
            default:
                XCTFail("expected to get \(expectedResult) but got \(result)", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
