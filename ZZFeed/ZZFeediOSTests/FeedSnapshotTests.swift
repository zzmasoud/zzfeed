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
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let  bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let ListViewController = storyboard.instantiateInitialViewController() as! ListViewController
        ListViewController.loadViewIfNeeded()
        ListViewController.tableView.showsVerticalScrollIndicator = false
        ListViewController.tableView.showsHorizontalScrollIndicator = false
        
        return ListViewController
    }
    
    private func emptyFeed() -> [ItemStub] {
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

private extension ListViewController {
    func display(_ stubs: [ItemStub]) {
        let cells = stubs.map { stub in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub)
            stub.controller = cellController
            return CellController(id: UUID(), dataSource: cellController)
        }
        display(cells)
    }
}

private class ItemStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    let image: UIImage?
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            description: description,
            location: location)
        self.image = image
    }
    
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))
        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel.noError)
        } else {
            controller?.display(ResourceErrorViewModel.error(message: "Error!"))
        }
    }
    
    func didCancelImageRequest() {}
}
