//
//  FeedLoader.swift
//  ZZFeed
//
//  Created by Masoud on 3/8/22.
//

import Foundation

public typealias FeedLoaderResult<Error: Swift.Error> = Result<[FeedItem], Error>

public protocol Feedloader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (FeedLoaderResult<Error>)->Void)
}
