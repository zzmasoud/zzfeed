//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class RemoteFeedItemDataLoader {
    private let client: HttpClient
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            default: break
            }
        }
    }
}

class RemoteFeedItemDataLoaderTests: XCTestCase {

    func test_init_doesNotRequestURLRequest() {
        let client = HttpClientSpy()
        let _ = RemoteFeedItemDataLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestDataFromURL() {
        let client = HttpClientSpy()
        let url = URL(string: "https://url.com")!
        let sut = RemoteFeedItemDataLoader(client: client)
        
        sut.loadImageData(from: url, completion: {_ in })
        XCTAssertEqual(client.requestedURLs, [url])
        
        
        sut.loadImageData(from: url, completion: {_ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let client = HttpClientSpy()
        let url = anyURL()
        let expectedError = anyNSError()
        let sut = RemoteFeedItemDataLoader(client: client)
        
        let exp = expectation(description: "waiting for completion...")
        sut.loadImageData(from: url) { result in
            do {
                let _ = try result.get()
                XCTFail("expected to get error")
            } catch {
                XCTAssertEqual((error as NSError), expectedError)
            }
        }
        
        client.complete(with: expectedError)
        exp.fulfill()
        
        wait(for: [exp], timeout: 1)
    }
    
    private class HttpClientSpy: HttpClient {
        var messages = [(url: URL, completion: (HttpClient.Result)->Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
