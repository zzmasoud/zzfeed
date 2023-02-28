//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZFeed

class FeedItemPresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let feedItem = uniqueFeedItem()
        
        let viewModel = FeedItemPresenter.map(feedItem)
        
        XCTAssertEqual(viewModel.description, feedItem.description)
        XCTAssertEqual(viewModel.location, feedItem.location)
    }
}

