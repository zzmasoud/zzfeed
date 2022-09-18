//
//  RemoteFeedItem.swift
//  ZZFeed
//
//  Created by Masoud on 29/8/22.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let image: URL
    internal let description: String?
    internal let location: String?
}
