//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public final class FeedItemPresenter {
    public static func map(_ item: FeedItem) -> FeedItemViewModel {
        FeedItemViewModel(
            description: item.description,
            location: item.location)
    }
}
