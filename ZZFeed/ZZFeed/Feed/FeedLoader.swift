//
//  FeedLoader.swift
//  ZZFeed
//
//  Created by Masoud on 3/8/22.
//

import Foundation

enum FeedLoaderResult {
    case success([FeedItem])
    case error(Error)
}

protocol Feedloader {
    func load(completion: @escaping (FeedLoaderResult)->Void)
}
