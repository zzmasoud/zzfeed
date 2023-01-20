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
    
    func loadImageData(from url: URL) {
        client.get(from: url) { result in
            
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
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    private class HttpClientSpy: HttpClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}
