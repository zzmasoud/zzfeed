//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public final class FeedItemPresenter {
    public static func map(_ item: FeedImage) -> FeedItemViewModel {
        FeedItemViewModel(
            description: item.description,
            location: item.location)
    }
}
