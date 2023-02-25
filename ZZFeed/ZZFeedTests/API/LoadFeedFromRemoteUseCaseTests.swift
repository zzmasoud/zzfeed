//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {

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

        expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.connectivity)) {
            let clientError = NSError(domain: "ClientError", code: -1)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, sut) = makeSUT()

        let codes = [199, 204, 291, 300, 400, 500]
        
        codes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData)) {
                let emptyJson = makeEmptyListJson()
                client.complete(withStatusCode: code, data: emptyJson, at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsOn200HttpResponseWithEmptyJson() {
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyJson = makeEmptyListJson()
            client.complete(withStatusCode: 200, data: emptyJson)
        }
    }
    
    func test_load_deliverItemsOn200HttpResponseWithJson() {
        let (client, sut) = makeSUT()
        
        let obj1 = makeFeedItem(
            imageURL: URL(string: "http://foo.bar")!
        )
        
        let obj2 = makeFeedItem(
            description: "+ description",
            location: "+ location",
            imageURL: URL(string: "http://bar.foo")!
        )
        
        let itemsJson = ["items": [obj1.json, obj2.json]]
        let items = [obj1.model, obj2.model]
        
        expect(sut, toCompleteWithResult: .success(items)) {
            let jsonData = try! JSONSerialization.data(withJSONObject: itemsJson)
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJson = Data("wrong data".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://foo.bar")!, file: StaticString = #file, line: UInt = #line) -> (client: HTTPClientSpy, sut: RemoteFeedLoader)  {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (client, sut)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion...")
        sut.load { receivedResult in
            switch  (receivedResult, expectedResult) {
            case let (.success(receivedItem), .success(expectedItem)):
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as! RemoteFeedLoader.Error, expectedError as! RemoteFeedLoader.Error, file: file, line: line)
                
            default:
                XCTFail("Expected result: \(expectedResult) but got: \(receivedResult) instead!", file: file, line: line)
            }
            
            exp.fulfill()
        }
                
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private func makeFeedItem(description: String? = nil, location: String? = nil, imageURL: URL) -> (json: [String: Any], model: FeedItem) {
        let item = FeedItem(description: description, location: location, imageURL: imageURL)
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].reduce(into: [String: Any](), { acc, e in
            if let value = e.value { acc[e.key] = value }
        })
        return (json, item)
    }
    
    private func makeEmptyListJson() -> Data {
        return Data("{ \"items\": [] }".utf8)
    }
}
