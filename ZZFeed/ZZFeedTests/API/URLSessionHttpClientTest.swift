//
//  URLSessionHttpClientTest.swift
//  ZZFeedTests
//
//  Created by Masoud on 5/8/22.
//

import XCTest

class URLSessionHttpClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHttpClientTest: XCTestCase {

    func test_getFromURL_createDataTaskWithURL() {
        let url = URL(string: "http://foo.bar")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHttpClient(session: session)
        sut.get(url: url)
        
        XCTAssertEqual(session.receivedUrls, [url])
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedUrls = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}

}
