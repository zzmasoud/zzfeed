//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UIKit
import Combine
import ZZFeed
import ZZFeediOS
import ZZFeedApp

final public class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    func test_imageSelection_notifiesHandler() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [image0, image1])

        sut.simulateTapOnFeedImage(at: 0)
        XCTAssertEqual(selectedImages, [image0])

        sut.simulateTapOnFeedImage(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
    
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3)
    }
    
    func test_loadMoreActions_requestMoreFromLoader() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0)
        
        XCTAssertEqual(loader.loadMoreCallCount, 0)

        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1)
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1)
    }

    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadFeedCompletion_renderSuccessfullyLoadedFeed() {
        let item0 = FeedImage(description: "abcd", location: nil, imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(description: "---", location: nil, imageURL: URL(string: "https://url1.com")!)
        let item2 = FeedImage(description: "no way", location: "locationA", imageURL: URL(string: "https://url.valid.com")!)
        let item3 = FeedImage(description: nil, location: "locationB", imageURL: URL(string: "https://url.vaaaali.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeFeedLoading(at: 0, with: [item0])
        assertThat(sut, isRendering: [item0])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(at: 1, with: [item0, item1, item2, item3])
        assertThat(sut, isRendering: [item0, item1, item2, item3])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(at: 2, with: [])
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotChangeCurrentRenderedStateOnError() {
        let item0 = FeedImage(description: "abcd", location: nil, imageURL: URL(string: "https://url.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0])
        assertThat(sut, isRendering: [item0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [item0])
    }
    
    func test_feedItemView_loadsImageURLWhenVisible() {
        let (sut, loader) = makeSUT()
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(imageURL: URL(string: "https://url-2nd.com")!)

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
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(imageURL: URL(string: "https://url-2nd.com")!)

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
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(imageURL: URL(string: "https://url-2nd.com")!)

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
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        
        let view0 = sut.simulateFeedItemViewVisible(at: 0)
        let view1 = sut.simulateFeedItemViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let image0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: image0, at: 0)
        XCTAssertEqual(view0?.renderedImage, image0)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let image1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: image1, at: 1)
        XCTAssertEqual(view0?.renderedImage, image0)
        XCTAssertEqual(view1?.renderedImage, image1)
    }
    
    func test_feedItemViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(imageURL: URL(string: "https://url-2nd.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0, item1])
        
        let view0 = sut.simulateFeedItemViewVisible(at: 0)
        let view1 = sut.simulateFeedItemViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        
        let image0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: image0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, true)
    }
    
    func test_feedItemViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0])
        
        let view0 = sut.simulateFeedItemViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        
        loader.completeImageLoading(with: Data("Invalid data".utf8))
        XCTAssertEqual(view0?.isShowingRetryAction, true)
    }
    
    func test_feedItemViewRetryAction_retriesImageLoad() {
        let (sut, loader) = makeSUT()
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(imageURL: URL(string: "https://url-2nd.com")!)

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
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(imageURL: URL(string: "https://url-2nd.com")!)

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
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let item1 = FeedImage(imageURL: URL(string: "https://url-2nd.com")!)

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
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        let imageData = UIImage.make(withColor: .blue).pngData()!
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
        let item0 = FeedImage(imageURL: URL(string: "https://url.com")!)
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, with: [item0])

        let view0 = sut.simulateFeedItemViewNotVisible(at: 0)
        loader.completeImageLoading()
        
        XCTAssertNil(view0?.renderedImage)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        selection: @escaping (FeedImage) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(
            feedLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            selection: selection
        )
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, imageURL: url)
    }

    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }

    
    // MARK: - LoaderSpy
    
    private class LoaderSpy: FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        
        var loadFeedCallCount: Int { feedRequests.count }
        
        private(set) var loadMoreCallCount = 0
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeFeedLoading(at index: Int, with feed: [FeedImage] = []) {
            feedRequests[index].send(Paginated(items: feed, loadMore: { [weak self] _ in
                self?.loadMoreCallCount += 1
            }))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            feedRequests[index].send(completion: .failure(anyNSError()))
        }
        
        // MARK: - FeedImageDataLoader

        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }

        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.LoadResult) -> Void)]()

        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }

        private(set) var cancelledImageURLs = [URL]()

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.LoadResult) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }

}
