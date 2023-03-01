//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit
import ZZFeediOS

extension ListViewController {
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()

        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }

    func simulateUserActionFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedItemViewVisible(at row: Int) -> FeedImageCell? {
        return feedItemView(at: row) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedItemViewNotVisible(at row: Int) -> FeedImageCell? {
        let cell = simulateFeedItemViewVisible(at: row)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
        return cell
    }
    
    func simulateFeedItemNearViewVisible(at row: Int) {
        let prefetchDataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        prefetchDataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedItemNearViewNotNearVisible(at row: Int) {
        simulateFeedItemNearViewVisible(at: row)
        
        let prefetchDataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing ?? false
    }
    
    var numberOfRenderedFeedItemViews: Int {
        return numberOfRows(in: feedImagesSection)
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
        
    func feedItemView(at row: Int) -> UITableViewCell? {
        guard numberOfRows(in: feedImagesSection) > row else { return nil }
        
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return dataSource?.tableView(tableView, cellForRowAt: index)
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedItemViewVisible(at: index)?.renderedImage
    }
    
    private var feedImagesSection: Int { 0 }
}
