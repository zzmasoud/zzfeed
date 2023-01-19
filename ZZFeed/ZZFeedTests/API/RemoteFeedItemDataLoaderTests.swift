//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest

class RemoteFeedItemDataLoader {
    init(client: Any) {}
}

class RemoteFeedItemDataLoaderTests: XCTestCase {

    func test_init_doesNotRequestURLRequest() {
        let client = HttpClientSpy()
        let _= RemoteFeedItemDataLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    private class HttpClientSpy {
        var requestedURLs = [URL]()
    }
}
