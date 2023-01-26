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
        case failed
    }
    
    private let store: FeedItemDataStore
    
    init(store: FeedItemDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) -> FeedItemDataLoaderTask {
        store.retrieve(dataForURL: url, completion: { _ in
            completion(.failure(Error.failed))
        })
        return Task()
    }
    
    private struct Task: FeedItemDataLoaderTask {
        func cancel() {}
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
        let retrievalError = anyNSError()
        
        let exp = expectation(description: "waiting for completion...")
        _ = sut.loadImageData(from: url, completion: { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("expected to get failure error but got \(result)")
            }
            
            exp.fulfill()
        })
        
        store.complete(with: retrievalError)
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedItemDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedItemDataLoader(store: store)

        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (sut, store)
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
    }
}
