//
//  FeedAPI.swift
//  ZZFeed
//
//  Created by Masoud Sheikh Hosseini on 8/3/22.
//

import Foundation

public enum HttpClientResult {
    case failure(Error)
    case success(HTTPURLResponse)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HttpClientResult)->Void)
}

public class RemoteFeedLoader {
    private let client: HttpClient
    private let url: URL
    
    public enum FeedLoadError: Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (FeedLoadError) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure:
                completion(.connectivity)
            case .success:
                completion(.invalidData)
            }
        }
    }
}
