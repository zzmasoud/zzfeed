//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import ZZFeed

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", imageURL: URL(string: "http://any-url.com")!)]
}

func primaryData() -> Data {
    return Data("primary data".utf8)
}

func fallbackData() -> Data {
    return Data("primary data".utf8)
}

func anyURL() -> URL {
    return URL(string: "https://u.rl")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
