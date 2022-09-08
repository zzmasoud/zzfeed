//
//  FeedCachePolicy.swift
//  ZZFeed
//
//  Created by Masoud Sheikh Hosseini on 9/8/22.
//

import Foundation

internal final class FeedCachePolicy {
    
    private static let calendar = Calendar.current
    
    private init() {}
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }

    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}
