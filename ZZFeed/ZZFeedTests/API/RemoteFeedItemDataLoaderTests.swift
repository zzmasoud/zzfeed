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
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.Result) -> Void) -> FeedItemDataLoaderTask {
        let task = HttpClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return}
            
            switch result {
            case .failure(let error):
                task.complete(with: .failure(error))
                
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            }
        }
        
        return task
    }
    
    private final class HttpClientTaskWrapper: FeedItemDataLoaderTask {
        private var completion: ((FeedItemDataLoader.Result) -> Void)?
        var wrapped: HttpClientTask?
        
        init(_ completion: @escaping (FeedItemDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedItemDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
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
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let code = 200
        
        expect(sut, toCompleteWith: .failure(RemoteFeedItemDataLoader.Error.invalidData)) {
            client.complete(withStatusCode: code, data: anyData())
        }
    }
    
    func test_loadImageDataFromURL_deliversReceivedDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let code = 200
        let expectedData = Data("this is a data".utf8)
        
        expect(sut, toCompleteWith: .success(expectedData)) {
            client.complete(withStatusCode: code, data: expectedData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceIsDeallocated() {
        let client = HttpClientSpy()
        var sut: RemoteFeedItemDataLoader? = RemoteFeedItemDataLoader(client: client)

        var results: [FeedItemDataLoader.Result] = []
        sut?.loadImageData(from: anyURL(), completion: {
            results.append($0)
        })
        
        sut = nil
        client.complete(with: NSError())
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url, completion: { _ in })
        XCTAssertTrue(client.cancelledTasks.isEmpty)

        
        task.cancel()
        XCTAssertEqual(client.cancelledTasks, [url])
    }
    
    func test_cancelLoadImageDataURLTask_doesntDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("this is a data".utf8)

        var receivedResults = [FeedItemDataLoader.Result]()
        
        let task = sut.loadImageData(from: anyURL(), completion: { receivedResults.append($0) })
        task.cancel()
        
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
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
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)
                
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
        
        var cancelledTasks: [URL] = []
        
        func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
            messages.append((url, completion))
            let task =  Task { [weak self] in
                self?.cancelledTasks.append(url)
            }
            
            return task
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
       
        private struct Task: HttpClientTask {
            let callback: () -> Void
            
            func cancel() {
                callback()
            }
        }
    }
}
