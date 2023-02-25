//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class RemoteLoaderTests: XCTestCase {

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

        expect(sut, toCompleteWithResult: .failure(RemoteLoader<String>.Error.connectivity)) {
            let clientError = NSError(domain: "ClientError", code: -1)
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnMapperError() {
        let (client, sut) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })
        
        expect(sut, toCompleteWithResult: .failure(RemoteLoader<String>.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: anyData())
        }
    }
    
    func test_load_deliversMappedResource() {
        let resource = "resource"
        let (client, sut) = makeSUT { data, _ in
            String(data: data, encoding: .utf8)!
        }
        
        expect(sut, toCompleteWithResult: .success(resource)) {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: { _, _ in "-" })
        
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
        
    private func makeSUT(
        url: URL = URL(string: "https://foo.bar")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "-" },
        file: StaticString = #file,
        line: UInt = #line) -> (client: HTTPClientSpy, sut: RemoteLoader<String>)  {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (client, sut)
    }
    
    private func expect(_ sut: RemoteLoader<String>, toCompleteWithResult expectedResult: RemoteLoader<String>.Result, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion...")
        sut.load { receivedResult in
            switch  (receivedResult, expectedResult) {
            case let (.success(receivedItem), .success(expectedItem)):
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as! RemoteLoader<String>.Error, expectedError as! RemoteLoader.Error, file: file, line: line)
                
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
