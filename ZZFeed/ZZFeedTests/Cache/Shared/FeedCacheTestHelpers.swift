//
//  FeedCacheTestHelpers.swift
//  ZZFeedTests
//
//  Created by Masoud Sheikh Hosseini on 9/8/22.
//

import Foundation

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return add(days: -feedCacheMaxAgeInDays)
    }
    
    func add(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    var feedCacheMaxAgeInDays: Int {
        return 7
    }
}
