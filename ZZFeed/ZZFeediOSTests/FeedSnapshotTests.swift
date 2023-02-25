//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
@testable import ZZFeediOS
import ZZFeed

final class FeedSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "EMPTY_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "EMPTY_FEED_dark")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_CONTENT_dark")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedViewController {
        let  bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.loadViewIfNeeded()
        feedViewController.tableView.showsVerticalScrollIndicator = false
        feedViewController.tableView.showsHorizontalScrollIndicator = false
        
        return feedViewController
    }
    
    private func emptyFeed() -> [FeedItemCellController] {
        return []
    }
    
    private func feedWithContent() -> [ItemStub] {
        return [
            ItemStub(
                description: "Long text, Long textLong text Long text.\ntextLong textLongtextLong textLong. ",
                location: "Location A",
                image: UIImage.make(withColor: .red)
            ),
            ItemStub(
                description: "Long text",
                location: nil,
                image: UIImage.make(withColor: .blue)
            ),
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ItemStub] {
        return [
            ItemStub(
                description: "Long text, Long textLong text Long text.\ntextLong textLongtextLong textLong. ",
                location: "Location A",
                image: nil
            ),
            ItemStub(
                description: "Long text",
                location: nil,
                image: nil
            ),
        ]
    }
} 

private extension FeedViewController {
    func display(_ stubs: [ItemStub]) {
        let cells: [FeedItemCellController] = stubs.map { stub in
            let cellController = FeedItemCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        display(cells)
    }
}

private class ItemStub: FeedItemCellControllerDelegate {
    let viewModel: FeedItemViewModel<UIImage>
    weak var controller: FeedItemCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedItemViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {}
}
