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
        let feed = [FeedItem(description: "abcd", location: nil, imageURL: URL(string: "https://url.com")!)]
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(0, sut.numberOfRenderedFeedItemViews)

        loader.completeFeedLoading(at: 0, with: feed)
        XCTAssertEqual(sut.numberOfRenderedFeedItemViews, feed.count)
        
        let view = sut.feedItemView(at: 0) as? FeedItemCell
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.isShowingLocation, false)
        XCTAssertEqual(view?.descriptionText, feed[0].description)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, loader)
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
