//
//  LocalFeedItem.swift
//  ZZFeed
//
//  Created by Masoud on 29/8/22.
//

import Foundation

public struct LocalFeedItem: Equatable, Codable {
    public let id: UUID
    public let imageURL: URL
    public let description: String?
    public let location: String?
    
    public init(id: UUID = UUID(), description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.imageURL = imageURL
        self.description = description
        self.location = location
    }
}
