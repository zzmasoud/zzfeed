//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

protocol FeedItemDataStore {
    func retrieve(dataForURL url: URL)
}

class LocalFeedItemDataLoader: FeedItemDataLoader {
    
    private let store: FeedItemDataStore
    
    init(store: FeedItemDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) -> FeedItemDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
    
    private struct Task: FeedItemDataLoaderTask {
        func cancel() {}
    }
}

class LocalFeedItemDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponRequest() {
        let store = StoreSpy()
        let _ = LocalFeedItemDataLoader(store: store)
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoreDataForURL() {
        let store = StoreSpy()
        let url = anyURL()
        let sut = LocalFeedItemDataLoader(store: store)
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataForURL: url)])
    }
    
    // MARK: - Helpers
    
    private class StoreSpy: FeedItemDataStore {
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
        }
        
        var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL) {
            receivedMessages.append(.retrieve(dataForURL: url))
        }
    }
}
