//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed


class LocalFeedItemDataLoaderTests: XCTestCase {
    
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
        let store = StoreSpy()
        var sut: LocalFeedItemDataLoader? = LocalFeedItemDataLoader(store: store)
        
        var capturedResults = [FeedItemDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL(), completion: { capturedResults.append($0)} )
        
        sut = nil
        
        store.complete(with: .none)

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = Data()
        let url = anyURL()
        
        sut.save(data: data, for: url)

        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedItemDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedItemDataLoader(store: store)

        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
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
    
    private class StoreSpy: FeedItemDataStore {
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
            case insert(data: Data, for: URL)
        }
        
        private var completions = [(FeedItemDataStore.RetrievalResult) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedItemDataStore.RetrievalResult) -> Void) {
            receivedMessages.append(.retrieve(dataForURL: url))
            completions.append(completion)
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
        
        func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, for: url))
        }
    }
}
