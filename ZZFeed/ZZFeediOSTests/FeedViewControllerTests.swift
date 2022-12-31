//
//  FeedViewControllerTests.swift
//  ZZFeediOSTests
//
//  Created by Masoud Sheikh Hosseini on 12/31/22.
//

import XCTest
import UIKit
import ZZFeed

public class FeedViewController: UITableViewController {
    private var loader: Feedloader?
    
    convenience init(loader: Feedloader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        
        load()
    }
    
    @objc private func load() {
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserActionFeedReload()
        XCTAssertEqual(loader.loadCount, 2)
        
        sut.simulateUserActionFeedReload()
        XCTAssertEqual(loader.loadCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorAfterLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_userActionReload_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.simulateUserActionFeedReload()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_userActionReload_hidesLoadingIndicatorAfterLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserActionFeedReload()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, loader)
    }
    
    class LoaderSpy: Feedloader {
        private var completions: [(Feedloader.Result) -> Void] = []
        
        var loadCount: Int { completions.count }
        
        func load(completion: @escaping (Feedloader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading() {
            completions[0](.success([]))
        }
    }
}

private extension FeedViewController {
    func simulateUserActionFeedReload() {
        refreshControl?.simulatePullToRefresh()
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
