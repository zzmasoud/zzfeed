//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public final class FeedPresenter {
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    public static func map(_ models: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: models)
    }
}
