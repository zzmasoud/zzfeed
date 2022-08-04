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

        except(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "ClientError", code: -1)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, sut) = makeSUT()

        let codes = [199, 204, 291, 300, 400, 500]
        
        codes.enumerated().forEach { index, code in
            except(sut, toCompleteWithResult: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsOn200HttpResponseWithEmptyJson() {
        let (client, sut) = makeSUT()
        
        except(sut, toCompleteWithResult: .success([])) {
            let emptyJson = Data("{ \"items\": [] }".utf8)
            client.complete(withStatusCode: 200, data: emptyJson)
        }
    }
    
    func test_load_deliverItemsOn200HttpResponseWithJson() {
        let (client, sut) = makeSUT()
        
        let obj1 = FeedItem(
            description: nil,
            location: nil,
            imageURL: URL(string: "http://foo.bar")!
        )
        
        let obj1Json = [
            "id": obj1.id.uuidString,
            "image": obj1.imageURL.absoluteString
        ]
        
        let obj2 = FeedItem(
            description: "+ description",
            location: "+ location",
            imageURL: URL(string: "http://bar.foo")!
        )
        
        let obj2Json = [
            "id": obj2.id.uuidString,
            "description": obj2.description,
            "location": obj2.location,
            "image": obj2.imageURL.absoluteString
        ]
        
        let itemsJson = [
            "items": [obj1Json, obj2Json]
        ]
        
        except(sut, toCompleteWithResult: .success([obj1, obj2])) {
            let jsonData = try! JSONSerialization.data(withJSONObject: itemsJson)
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
        let (client, sut) = makeSUT()
        
        except(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJson = Data("wrong data".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://foo.bar")!) -> (client: TestHttpClient, sut: RemoteFeedLoader)  {
        let client = TestHttpClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (client, sut)
    }
    
    private func except(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
