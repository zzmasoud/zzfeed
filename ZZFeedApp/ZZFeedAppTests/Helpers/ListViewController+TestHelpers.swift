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
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }

    func simulateErrorViewTap() {
        errorView.simulateTap()
    }

    var errorMessage: String? {
        return errorView.message
    }

    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }

    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

// MARK: - Feed

extension ListViewController {
    @discardableResult
    func simulateFeedItemViewVisible(at row: Int) -> FeedImageCell? {
        return feedImageView(at: row) as? FeedImageCell
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
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }

    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedItemViewVisible(at: index)?.renderedImage
    }

    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRows(in: feedImagesSection)
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: feedImagesSection)
    }

    private var feedImagesSection: Int { 0 }
}

// MARK: - Comments

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        numberOfRows(in: commentsSection)
    }

    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }

    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }

    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }

    private func commentView(at row: Int) -> ImageCommentCell? {
        cell(row: row, section: commentsSection) as? ImageCommentCell
    }

    private var commentsSection: Int { 0 }
}
