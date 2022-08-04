//
//  FeedItem.swift
//  ZZFeed
//
//  Created by Masoud on 2/8/22.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let imageURL: URL
    public let description: String?
    public let location: String?
    
    public init(description: String?, location: String?, imageURL: URL) {
        self.id = UUID()
        self.imageURL = imageURL
        self.description = description
        self.location = location
    }
}

extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
