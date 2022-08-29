//
//  FeedItemsMapper.swift
//  ZZFeed
//
//  Created by Masoud Sheikh Hosseini on 8/5/22.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let image: URL
    internal let description: String?
    internal let location: String?
}

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var HTTP_OK200: Int { 200 }
    
    internal static func map(data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == HTTP_OK200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.FeedLoadError.invalidData
        }
        
        return root.items
    }

}
