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
    
    public init(id: UUID = UUID(), description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.imageURL = imageURL
        self.description = description
        self.location = location
    }
}
