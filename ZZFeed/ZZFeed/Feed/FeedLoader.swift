//
//  FeedLoader.swift
//  ZZFeed
//
//  Created by Masoud on 3/8/22.
//

import Foundation


public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedItem], Error>
    
    func load(completion: @escaping (Result)->Void)
}
