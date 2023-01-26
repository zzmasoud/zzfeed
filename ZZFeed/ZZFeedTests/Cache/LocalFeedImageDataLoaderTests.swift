//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation
import XCTest

class LocalFeedItemDataLoader {
    init(store: Any) {}
}

class LocalFeedItemDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponRequest() {
        let store = FeedStoreSpy()
        let _ = LocalFeedItemDataLoader(store: store)
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }
}
