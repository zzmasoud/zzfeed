//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public final class FeedImagePresenter {
    public static func map(_ item: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: item.description,
            location: item.location)
    }
}
