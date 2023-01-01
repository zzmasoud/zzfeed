//
//  FeedViewControllerTests.swift
//  ZZFeediOSTests
//
//  Created by zzmasoud on 12/31/22.
//

import XCTest
import UIKit
import ZZFeed
import ZZFeediOS

final public class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCount, 1)
    
        sut.simulateUserActionFeedReload()
        XCTAssertEqual(loader.loadCount, 2)
        
        sut.simulateUserActionFeedReload()
        XCTAssertEqual(loader.loadCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserActionFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        sut.simulateUserActionFeedReload()
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadFeedCompletion_renderSuccessfullyLoadedFeed() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(description: "abcd", location: nil, imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(description: "---", location: nil, imageURL: URL(string: "https://url1.com")!)
        let item2 = FeedItem(description: "no way", location: "locationA", imageURL: URL(string: "https://url.valid.com")!)
        let item3 = FeedItem(description: nil, location: "locationB", imageURL: URL(string: "https://url.vaaaali.com")!)

        sut.loadViewIfNeeded()
        XCTAssertEqual(0, sut.numberOfRenderedFeedItemViews)

        loader.completeFeedLoading(at: 0, with: [item0])
        assert(sut, isRendering: [item0])
        
        sut.simulateUserActionFeedReload()
        loader.completeFeedLoading(at: 1, with: [item0, item1, item2, item3])
        assert(sut, isRendering: [item0, item1, item2, item3])
        
        sut.simulateUserActionFeedReload()
        loader.completeFeedLoading(at: 2, with: [])
        assert(sut, isRendering: [])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, loader)
    }
    
    private func assert(_ sut: FeedViewController, isRendering feed: [FeedItem], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedItemViews == feed.count else {
            return XCTFail("expected \(feed.count) but got \(sut.numberOfRenderedFeedItemViews) .")
        }
        
        for (index, item) in feed.enumerated() {
            assert(sut, hasConfiguaredViewFor: item, at: index)
        }
    }
    
    private func assert(_ sut: FeedViewController, hasConfiguaredViewFor feedItem: FeedItem, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedItemView(at: index) as? FeedItemCell
        
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.isShowingLocation, feedItem.location != nil)
        XCTAssertEqual(view?.locationText, feedItem.location)
        XCTAssertEqual(view?.descriptionText, feedItem.description)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions: [(FeedLoader.Result) -> Void] = []
        
        var loadCount: Int { completions.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int, with feed: [FeedItem] = []) {
            completions[index](.success(feed))
        }
    }
}

private extension FeedViewController {
    func simulateUserActionFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing ?? false
    }
    
    var numberOfRenderedFeedItemViews: Int {
        return tableView.numberOfRows(inSection: 0)
    }
    
    func feedItemView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: 0)
        return dataSource?.tableView(tableView, cellForRowAt: index)
    }
}

private extension FeedItemCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
}

// MARK: - UIRefreshControl + Simulate

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ selector in
                (target as NSObject).perform(Selector(selector))
            })
        })
    }
}
