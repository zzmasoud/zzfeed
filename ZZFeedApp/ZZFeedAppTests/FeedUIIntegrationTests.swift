//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UIKit
import ZZFeed
import ZZFeediOS
import ZZFeedApp

final public class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
    
        sut.simulateUserActionFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
        
        sut.simulateUserActionFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserActionFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

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
    
    func test_loadFeedCompletion_doesNotChangeCurrentRenderedStateOnError() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(description: "abcd", location: nil, imageURL: URL(string: "https://url.com")!)

        sut.loadViewIfNeeded()
        XCTAssertEqual(0, sut.numberOfRenderedFeedItemViews)

        loader.completeFeedLoading(at: 0, with: [item0])
        assert(sut, isRendering: [item0])
        
        sut.simulateUserActionFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assert(sut, isRendering: [item0])
    }
    
    func test_feedItemView_loadsImageURLWhenVisible() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        XCTAssertEqual(loader.loadedImageURLs, [])

        sut.simulateFeedItemViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL])
        
        sut.simulateFeedItemViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL])
    }
    
    func test_feedItemView_CancelsImageURLWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        XCTAssertEqual(loader.loadedImageURLs, [])

        sut.simulateFeedItemViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.imageURL])

        sut.simulateFeedItemViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.imageURL, item1.imageURL])
    }
    
    func test_feedItemViewLoadingIndicator_isVisibleWhileLoading() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        
        let view0 = sut.simulateFeedItemViewVisible(at: 0)
        let view1 = sut.simulateFeedItemViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        
        loader.completeImageLoading()
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
    }
    
    func test_feedItemView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        
        let view0 = sut.simulateFeedItemViewVisible(at: 0)
        let view1 = sut.simulateFeedItemViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let image0 = UIImage.init(color: .red)!.pngData()!
        loader.completeImageLoading(with: image0, at: 0)
        XCTAssertEqual(view0?.renderedImage, image0)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let image1 = UIImage.init(color: .blue)!.pngData()!
        loader.completeImageLoading(with: image1, at: 1)
        XCTAssertEqual(view0?.renderedImage, image0)
        XCTAssertEqual(view1?.renderedImage, image1)
    }
    
    func test_feedItemViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        
        let view0 = sut.simulateFeedItemViewVisible(at: 0)
        let view1 = sut.simulateFeedItemViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        
        let image0 = UIImage.init(color: .red)!.pngData()!
        loader.completeImageLoading(with: image0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, true)
    }
    
    func test_feedItemViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0])
        
        let view0 = sut.simulateFeedItemViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        
        loader.completeImageLoading(with: Data("Invalid data".utf8))
        XCTAssertEqual(view0?.isShowingRetryAction, true)
    }
    
    func test_feedItemViewRetryAction_retriesImageLoad() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        
        let view0 = sut.simulateFeedItemViewVisible(at: 0)
        let view1 = sut.simulateFeedItemViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL])
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL])

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL, item0.imageURL])

        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL, item0.imageURL, item1.imageURL])
    }
    
    func test_feedItemView_preloadsImageURLWhenNearVisible() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedItemNearViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL])
        
        sut.simulateFeedItemNearViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL])
    }
    
    func test_feedItemView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedItem(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        XCTAssertEqual(loader.cancelledImageURLs, [])
        
        sut.simulateFeedItemNearViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.imageURL])
        
        sut.simulateFeedItemNearViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.imageURL, item1.imageURL])
    }
    
    func test_loadFeedCompletion_dispatchesfromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "waiting for background queue...")
        DispatchQueue.global(qos: .background).async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImageDataCompletion_dispatchesfromBackgroundToMainThread() {
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        let imageData = UIImage.init(color: .blue)!.pngData()!
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0])
        sut.simulateFeedItemViewVisible(at: 0)

        let exp = expectation(description: "waiting for background queue...")
        DispatchQueue.global(qos: .background).async {
            loader.completeImageLoading(with: imageData, at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_testFeedItemView_doesNotRenderLoadedImageWhenNotVisible() {
        let (sut, loader) = makeSUT()
        let item0 = FeedItem(imageURL: URL(string: "https://url.com")!)
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0])

        let view0 = sut.simulateFeedItemViewNotVisible(at: 0)
        loader.completeImageLoading()
        
        XCTAssertNil(view0?.renderedImage)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader.loadPublisher, imageLoader: loader.loadImageDataPublisher)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, loader)
    }
    
    private func assert(_ sut: FeedViewController, isRendering feed: [FeedItem], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        guard sut.numberOfRenderedFeedItemViews == feed.count else {
            return XCTFail("expected \(feed.count) but got \(sut.numberOfRenderedFeedItemViews) .")
        }
        
        for (index, item) in feed.enumerated() {
            assert(sut, hasConfiguaredViewFor: item, at: index)
        }
    }
    
    private func assert(_ sut: FeedViewController, hasConfiguaredViewFor feedItem: FeedItem, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedItemView(at: index)
        
        guard let view = view as? FeedItemCell else {
            return XCTFail("Expected \(FeedItemCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(view.isShowingLocation, feedItem.location != nil)
        XCTAssertEqual(view.locationText, feedItem.location)
        XCTAssertEqual(view.descriptionText, feedItem.description)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing string in the table \(table) for key \(key)", file: file, line: line)
        }
        return value
    }
    
    class LoaderSpy: FeedLoader, FeedItemDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests: [(FeedLoader.Result) -> Void] = []
        
        var loadFeedCallCount: Int { feedRequests.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(at index: Int, with feed: [FeedItem] = []) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            feedRequests[index](.failure(NSError(domain: "error", code: -1)))
        }
        
        // MARK: - FeedItemDataLoader
        
        private struct TaskSpy: FeedItemDataLoaderTask {
            let cancelCallback: ()->Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests: [(url: URL, completion: (FeedItemDataLoader.LoadResult) -> Void)] = []
        private(set) var cancelledImageURLs: [URL] = []
        var loadedImageURLs: [URL] {
            imageRequests.map({ $0.url })
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedItemDataLoader.LoadResult) -> Void) -> FeedItemDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }

        func completeImageLoading(with imageData: Data = UIImage.init(color: .red)!.pngData()!, at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "loading error", code: -2)
            imageRequests[index].completion(.failure(error))
        }
    }
}

private extension FeedViewController {
    func simulateUserActionFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedItemViewVisible(at row: Int) -> FeedItemCell? {
        return feedItemView(at: row) as? FeedItemCell
    }
    
    @discardableResult
    func simulateFeedItemViewNotVisible(at row: Int) -> FeedItemCell? {
        let cell = simulateFeedItemViewVisible(at: row)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: 0)
        delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
        return cell
    }
    
    func simulateFeedItemNearViewVisible(at row: Int) {
        let prefetchDataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: 0)
        prefetchDataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedItemNearViewNotNearVisible(at row: Int) {
        simulateFeedItemNearViewVisible(at: row)
        
        let prefetchDataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: 0)
        prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
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
    
    var isShowingLoadingIndicator: Bool {
        return container.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !retryButton.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}

// MARK: - UIButton + Simulate

private extension UIButton {
    func simulateTap() {
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({ selector in
                (target as NSObject).perform(Selector(selector))
            })
        })
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

private extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
