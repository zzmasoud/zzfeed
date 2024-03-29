//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation
import ZZFeed


func uniqueFeedItem() -> FeedImage {
    return FeedImage(id: UUID(), description: "description...", location: "-", imageURL: anyURL())
}

func uniqueItems() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let items = [uniqueFeedItem(), uniqueFeedItem()]
    let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
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

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }

    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
