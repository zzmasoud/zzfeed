//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZFeed

class ImageCommentsPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("COMMENTS_VIEW_TITLE"))
    }

    func test_map_createsViewModel() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let comments = makeImageComments(now, calendar)
        let locale = Locale(identifier: "en_US")

        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )

        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "any",
                date: "39 minutes ago",
                username: "any name"
            ),
            ImageCommentViewModel(
                message: "any",
                date: "30 seconds ago",
                username: "any name"
            ),
        ])
    }

    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Comment"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

    private func makeImageComments(_ now: Date, _ calendar: Calendar = Calendar.current) -> [ImageComment] {
        return [
            uniqueImageComment(now
                .adding(minutes: -40, calendar: calendar)
                .adding(seconds: 30)
            ),
            uniqueImageComment(now
                .adding(seconds: -30)
            )
        ]
    }

    private func uniqueImageComment(_ createdAt: Date) -> ImageComment {
        return ImageComment(
            id: UUID(),
            message: "any",
            createdAt: createdAt,
            username: "any name"
        )
    }
}
