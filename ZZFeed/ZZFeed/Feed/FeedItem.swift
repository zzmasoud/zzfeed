//
//  FeedItem.swift
//  ZZFeed
//
//  Created by Masoud on 2/8/22.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let imageURL: URL
    let description: String?
    let location: String?
}
