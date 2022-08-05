//
//  FeedLoader.swift
//  ZZFeed
//
//  Created by Masoud on 3/8/22.
//

import Foundation

public enum FeedLoaderResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol Feedloader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (FeedLoaderResult<Error>)->Void)
}
