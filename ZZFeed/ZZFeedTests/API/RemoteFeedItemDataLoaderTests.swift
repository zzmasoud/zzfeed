//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class RemoteFeedItemDataLoader {
    private let client: HttpClient
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success:
                completion(.failure(Error.invalidData))
            }
        }
    }
}

class RemoteFeedItemDataLoaderTests: XCTestCase {

    func test_init_doesNotRequestURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImageData(from: url, completion: {_ in })
        XCTAssertEqual(client.requestedURLs, [url])
        
        
        sut.loadImageData(from: url, completion: {_ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let expectedError = anyNSError()
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(expectedError)) {
            client.complete(with: expectedError)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let codes = [190, 200, 203, 404, 500]
        
        codes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteFeedItemDataLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedItemDataLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedItemDataLoader(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedItemDataLoader, toCompleteWith expectedResult: FeedItemDataLoader.Result, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion....")
        sut.loadImageData(from: anyURL()) { result in
            switch (result, expectedResult) {
            case let (.success(_), .success(_)): break
            case let (.failure(error as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            case let (.failure(error as RemoteFeedItemDataLoader.Error), .failure(expectedError as RemoteFeedItemDataLoader.Error)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("expected to get \(expectedResult) but got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private func anyData() -> Data {
        return Data()
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

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
