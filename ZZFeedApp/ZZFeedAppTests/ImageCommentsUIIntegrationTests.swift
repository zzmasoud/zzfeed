//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UIKit
import Combine
import ZZFeed
import ZZFeediOS
import ZZFeedApp

final public class ImageCommentsUIIntegrationTests: XCTestCase {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, commentsTitle)
    }

    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no request until previous completes")

        loader.completeCommentsLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")

        loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a description", username: "a username")
        let comment1 = makeComment(username: "another username")
        let comment2 = makeComment(message: "another message")
        let comment3 = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1, comment2, comment3], at: 1)
        assertThat(sut, isRendering: [comment0, comment1, comment2, comment3])
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment0 = makeComment(message: "no way!")
        let comment1 = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 0)
        assertThat(sut, isRendering: [comment0, comment1])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }

    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment0 = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment0])
    }

    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    func test_deinit_cancelsRunningRequest() {
        var cancelCallCount = 0
        var sut: ListViewController?

        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith(commentsLoader: {
                PassthroughSubject<[ImageComment], Error>()
                    .handleEvents(receiveCancel: {
                        cancelCallCount += 1
                    }).eraseToAnyPublisher()
            })
            sut?.loadViewIfNeeded()
        }

        XCTAssertEqual(cancelCallCount, 0)

        sut = nil

        XCTAssertEqual(cancelCallCount, 1)
    }

    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(
            commentsLoader: loader.loadPublisher
        )
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeComment(message: String = "message", date: Date = Date(), username: String = "username") -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: date, username: username)
    }

    // MARK: - LoaderSpy

    private class LoaderSpy {
        private var requests = [PassthroughSubject<[ImageComment], Error>]()

        var loadCommentsCallCount: Int {
            return requests.count
        }

        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
            requests[index].send(completion: .finished)
        }

        func completeCommentsLoadingWithError(at index: Int = 0) {
            requests[index].send(completion: .failure(anyNSError()))
        }
    }
}
