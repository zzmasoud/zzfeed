//
//  FeedItemsMapper.swift
//  ZZFeed
//
//  Created by Masoud Sheikh Hosseini on 8/5/22.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            items.map({$0.feedItem})
        }
    }

    private struct Item: Decodable {
        public let id: UUID
        public let image: URL
        public let description: String?
        public let location: String?
        
        var feedItem: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static var HTTP_OK200: Int { 200 }
    
    internal static func map(data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == HTTP_OK200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        
        return .success(root.feed)
    }

}
