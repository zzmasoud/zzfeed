//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        NSLocalizedString(
            "COMMENTS_VIEW_TITLE",
            tableName: "Comment",
            bundle: Bundle(for: ImageCommentsPresenter.self),
            comment: "Title for the comments view")
    }

    public static func map(
        _ comments: [ImageComment],
        currentDate now: Date = Date(),
        calendar: Calendar = Calendar.current,
        locale: Locale = Locale.current
    ) -> ImageCommentsViewModel {
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = locale
        return ImageCommentsViewModel(comments: comments.map { comment in
            ImageCommentViewModel(
                message: comment.message,
                date: dateFormatter.localizedString(for: comment.createdAt, relativeTo: now),
                username: comment.username
            ) }
        )
    }
}
