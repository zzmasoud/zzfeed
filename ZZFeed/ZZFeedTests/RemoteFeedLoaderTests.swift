//
//  RemoteFeedLoaderTests.swift
//  ZZFeedTests
//
//  Created by Masoud Sheikh Hosseini on 8/3/22.
//

import XCTest
import ZZFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotReqDataFromURL() {
        let (client, _) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_reqDataFromURL() {
        let url = URL(string: "https://v1.api.com")!
        let (client, sut) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url, url])
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://foo.bar")!) -> (client: TestHttpClient, sut: RemoteFeedLoader)  {
        let client = TestHttpClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (client, sut)
    }
    
    private class TestHttpClient: HttpClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
            requestedURLs.append(url)
        }
    }
}
