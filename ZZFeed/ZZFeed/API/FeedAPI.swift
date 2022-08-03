//
//  FeedAPI.swift
//  ZZFeed
//
//  Created by Masoud Sheikh Hosseini on 8/3/22.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL)
}

public class RemoteFeedLoader {
    private let client: HttpClient
    private let url: URL
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: url)
    }
}
