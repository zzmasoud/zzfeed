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
        
        _ = try? sut.loadImageData(from: url)
        
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
    
    func test_loadImageDataFromURL_deliversDataOnStoreFoundData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith: found(data)) {
            store.complete(with: data)
        }
    }
        
    // MARK: - Helpers
    
    private typealias LoadResult = Result<Data, Error>
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, store)
    }
    
    private func failed() -> LoadResult {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> LoadResult {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func found(_ data: Data) -> LoadResult {
        return .success(data)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        action()
        
        let receivedResult = Result { try sut.loadImageData(from: anyURL()) }
            switch (receivedResult, expectedResult) {
            case (.failure(let error as LocalFeedImageDataLoader.LoadError),
                  .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(error , expectedError, file: file, line: line)
                
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData)
                
            default:
                XCTFail("expected to get \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
    }
}
