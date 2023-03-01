//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZFeed
import ZZFeediOS

extension FeedUIIntegrationTests {
    func assertThat(_ sut: ListViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        sut.view.enforceLayoutCycle()

        guard sut.numberOfRenderedFeedItemViews == feed.count else {
            return XCTFail("expected \(feed.count) but got \(sut.numberOfRenderedFeedItemViews) .")
        }
        
        for (index, item) in feed.enumerated() {
            assertThat(sut, hasConfiguaredViewFor: item, at: index)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assertThat(_ sut: ListViewController, hasConfiguaredViewFor feedItem: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedItemView(at: index)
        
        guard let view = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(view.isShowingLocation, feedItem.location != nil)
        XCTAssertEqual(view.locationText, feedItem.location)
        XCTAssertEqual(view.descriptionText, feedItem.description)
    }
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing string in the table \(table) for key \(key)", file: file, line: line)
        }
        return value
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}
