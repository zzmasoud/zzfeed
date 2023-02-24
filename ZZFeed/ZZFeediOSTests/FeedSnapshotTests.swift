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
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedViewController {
        let  bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.loadViewIfNeeded()
        return feedViewController
    }
    
    private func emptyFeed() -> [FeedItemCellController] {
        return []
    }
    
    private func feedWithContent() -> [ItemStub] {
        return [
            ItemStub(description: "Long text, Long textLong text Long text.\ntextLong textLongtextLong textLong.", location: "Location A", image: UIImage(color: .red)!),
            ItemStub(description: "Long text", location: "Location B, Bbb", image: UIImage(color: .blue)!),
        ]
    }
    
    private func record(snapshot: UIImage, named: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("failed to generate PNG file from the snapshot UIImage", file: file, line: line)
            return
        }
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(named).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("failed to save snapshot data with error: \(error)", file: file, line: line)
        }
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
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
