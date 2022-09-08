//
//  FeedCachePolicy.swift
//  ZZFeed
//
//  Created by Masoud Sheikh Hosseini on 9/8/22.
//

import Foundation

internal final class FeedCachePolicy {
    
    private let calendar = Calendar.current
    
    private var maxCacheAgeInDays: Int {
        return 7
    }

    func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}
