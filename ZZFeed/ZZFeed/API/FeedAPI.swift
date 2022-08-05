//
//  FeedAPI.swift
//  ZZFeed
//
//  Created by Masoud Sheikh Hosseini on 8/3/22.
//

import Foundation

public class RemoteFeedLoader: Feedloader {
    private let client: HttpClient
    private let url: URL
    
    public enum FeedLoadError: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoaderResult<FeedLoadError>

    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case let .success(data, response):
                completion(FeedItemsMapper.map(data: data, from: response))
            }
        }
    }
}
