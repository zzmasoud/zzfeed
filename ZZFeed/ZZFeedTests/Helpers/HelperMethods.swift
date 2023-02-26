//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation
import ZZFeed


func uniqueFeedItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "description...", location: "-", imageURL: anyURL())
}

func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
    let items = [uniqueFeedItem(), uniqueFeedItem()]
    let localItems = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    return (items, localItems)
}

func anyURL() -> URL {
    return URL(string: "http://foo.bar")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    return Data()
}
