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
    
    func test_load_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()

        var capturedErrors = [RemoteFeedLoader.FeedLoadError]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "ClientError", code: -1)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, sut) = makeSUT()

        let codes = [199, 204, 291, 300, 400, 500]
        
        codes.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.FeedLoadError]()
            sut.load { capturedErrors.append($0) }

            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
        let (client, sut) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.FeedLoadError]()
        sut.load { capturedErrors.append($0) }
        
        let invalidJson = Data("wrong data".utf8)
        client.complete(withStatusCode: 200, data: invalidJson)
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://foo.bar")!) -> (client: TestHttpClient, sut: RemoteFeedLoader)  {
        let client = TestHttpClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (client, sut)
    }
    
    private class TestHttpClient: HttpClient {
        var messages = [(url: URL, completion: (HttpClientResult)->Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
