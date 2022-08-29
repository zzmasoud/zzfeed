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
            case let .success(data, response):
                completion(Self.map(data, from: response))

            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data: data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error as! RemoteFeedLoader.FeedLoadError)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
