//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

protocol FeedItemDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

class LocalFeedItemDataLoader: FeedItemDataLoader {
    public enum Error: Swift.Error {
        case failed, notFound
    }
    
    private let store: FeedItemDataStore
    
    init(store: FeedItemDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) -> FeedItemDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url, completion: { result in
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    data == nil ? .failure(Error.notFound) : .success(data!)
                }
            )
        })
        
        return task
    }
    
    private final class Task: FeedItemDataLoaderTask {
        private var completion: ((FeedItemDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedItemDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedItemDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
}

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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedItemDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedItemDataLoader(store: store)

        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (sut, store)
    }
    
    private func failed() -> FeedItemDataLoader.Result {
        return .failure(LocalFeedItemDataLoader.Error.failed)
    }
    
    private func notFound() -> FeedItemDataLoader.Result {
        return .failure(LocalFeedItemDataLoader.Error.notFound)
    }
    
    private func found(_ data: Data) -> FeedItemDataLoader.Result {
        return .success(data)
    }
    
    private func expect(_ sut: LocalFeedItemDataLoader, toCompleteWith expectedResult: LocalFeedItemDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion...")
        _ = sut.loadImageData(from: anyURL(), completion: { result in
            switch (result, expectedResult) {
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as! LocalFeedItemDataLoader.Error , expectedError as! LocalFeedItemDataLoader.Error, file: file, line: line)
                
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
        }
        
        private var completions = [(FeedItemDataStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedItemDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataForURL: url))
            completions.append(completion)
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
