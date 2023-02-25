//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class LoadItemCommentsFromRemoteUseCaseTests: XCTestCase {
        
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [10, 199, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        let invalidJSON = Data("invalid json".utf8)
        
        let samples = [200, 201, 204, 220, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            })
        }
    }
    
    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let emptyListJSON = makeItemsJSON([])
      
        let samples = [200, 201, 204, 220, 299]
 
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([]), when: {
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            })
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
        let item1 = makeItem(
            message: "a message!",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "John")
        
        let item2 = makeItem(
            message: "a new message!",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "Johny")
        
        let items = [item1.model, item2.model]
        let json = makeItemsJSON([item1.json, item2.json])
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 204, 220, 299]
 
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items), when: {
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteItemCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteItemCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteItemCommentsLoader.Error) -> RemoteItemCommentsLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID = UUID(), message: String, createdAt: (date: Date, isoString: String), username: String) -> (model: FeedItemComment, json: [String: Any]) {
        let item = FeedItemComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.isoString,
            "author": [
                "username": username
            ]
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteItemCommentsLoader, toCompleteWith expectedResult: RemoteItemCommentsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}

