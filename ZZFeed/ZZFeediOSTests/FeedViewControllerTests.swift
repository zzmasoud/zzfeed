//
//  FeedViewControllerTests.swift
//  ZZFeediOSTests
//
//  Created by Masoud Sheikh Hosseini on 12/31/22.
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
