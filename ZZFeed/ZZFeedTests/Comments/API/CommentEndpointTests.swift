//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class CommentEndpointTests: XCTestCase {
    func test_comments_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        let id = UUID()

        let received = CommentEndpoint.get(id).url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v1/image/\(id.uuidString)/comments")!

        XCTAssertEqual(received, expected)
    }
}
