//
//  RemoteFeedLoaderTests.swift
//  ZZFeedTests
//
//  Created by Masoud Sheikh Hosseini on 8/3/22.
//

import XCTest

protocol HttpClient {
    func get(from url: URL)
}

class RemoteFeedLoader {
    let client: HttpClient
    let url: URL
    
    init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotReqDataFromURL() {
        
    }
    
    func test_load_reqDataFromURL() {
        
    }
    
    // MARK: - Helpers
    
    private class TestHttpClient: HttpClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
