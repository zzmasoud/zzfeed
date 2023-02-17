//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest

class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresentationTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        let _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private class ViewSpy {
        private(set) var messages: [Any] = []
    }
}
