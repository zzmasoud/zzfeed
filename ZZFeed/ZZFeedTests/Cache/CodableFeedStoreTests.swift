//
//  CodableFeedStoreTests.swift
//  ZZFeedTests
//
//  Created by Masoud on 12/4/22.
//

import XCTest
import ZZFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for completion...")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("expected empty but got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for completion...")
        sut.retrieve { fResult in
            sut.retrieve { sResult in
                switch (fResult, sResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("expected both empty but got \(fResult) and \(sResult)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
}
