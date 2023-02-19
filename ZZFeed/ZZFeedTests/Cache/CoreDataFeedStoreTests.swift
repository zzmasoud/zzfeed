//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZFeed

class CoreDataFeedStore: FeedStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(_ items: [ZZFeed.LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.empty))
    }
}

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CoreDataFeedStore()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFetchedValuesOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
}
