//
//  Copyright © zzmasoud (github.com/zzmasoud).
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
