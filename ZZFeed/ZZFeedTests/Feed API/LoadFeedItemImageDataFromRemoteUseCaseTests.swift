//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class LoadFeedItemImageDataFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: url, completion: {_ in })
        XCTAssertEqual(client.requestedURLs, [url])
        
        
        _ = sut.loadImageData(from: url, completion: {_ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let expectedError = RemoteFeedItemDataLoader.Error.connectivity
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
        let client = HTTPClientSpy()
        var sut: RemoteFeedItemDataLoader? = RemoteFeedItemDataLoader(client: client)

        var results: [FeedItemDataLoader.LoadResult] = []
        _ = sut?.loadImageData(from: anyURL(), completion: {
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

        var receivedResults = [FeedItemDataLoader.LoadResult]()
        
        let task = sut.loadImageData(from: anyURL(), completion: { receivedResults.append($0) })
        task.cancel()
        
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedItemDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedItemDataLoader(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedItemDataLoader, toCompleteWith expectedResult: RemoteFeedItemDataLoader.LoadResult, when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion....")
        _ = sut.loadImageData(from: anyURL()) { result in
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
}
