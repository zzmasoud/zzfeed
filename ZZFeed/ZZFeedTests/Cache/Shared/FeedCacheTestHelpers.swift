//
//  FeedCacheTestHelpers.swift
//  ZZFeedTests
//
//  Created by zzmasoud on 9/8/22.
//

import Foundation

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return add(days: -feedCacheMaxAgeInDays)
    }
    
    var feedCacheMaxAgeInDays: Int {
        return 7
    }
}

extension Date {
    func add(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}
