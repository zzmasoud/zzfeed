//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeEmptyListJson()
        let samples = [199, 204, 291, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HttpResponseWithInvalidJson() {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HttpResponseWithEmptyJson() throws {
        let emptyJson = makeEmptyListJson()
        
        let result = try FeedItemsMapper.map(emptyJson, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliverItemsOn200HttpResponseWithJson() throws {
        let obj1 = makeFeedItem(
            imageURL: URL(string: "http://foo.bar")!
        )
        
        let obj2 = makeFeedItem(
            description: "+ description",
            location: "+ location",
            imageURL: URL(string: "http://bar.foo")!
        )
        
        let json = makeItemsJSON([obj1.json, obj2.json])
        
        let result = try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [obj1.model, obj2.model])
    }
    
    // MARK: - Helpers
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
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
