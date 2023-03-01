//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZFeediOS
@testable import ZZFeed

class ImageCommentsSnapshotTests: XCTestCase {
    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(comments())

        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "IMAGE_COMMENT_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "IMAGE_COMMENT_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENT_WITH_CONTENT_light_extraExtraExtraLarge")
    }

    // MARK: - Helpers

    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func comments() -> [CellController] {
        return [
            ImageCommentViewModel(
                message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                date: "2 years ago",
                username: "Diego Armando Maradona Franco "
            ),
            ImageCommentViewModel(
                message: "Garth Pier is a Grade II listed\n structure in Bangor,\n Gwynedd, North Wales.",
                date: "30 minutes ago",
                username: "John Legend"
            ),
            ImageCommentViewModel(
                message: "or heritage-protected landmark.",
                date: "1 minute ago",
                username: "mr.nobody"
            )
        ].map { CellController(id: UUID(), dataSource: ImageCommentCellController(viewModel: $0)) }
    }
}
