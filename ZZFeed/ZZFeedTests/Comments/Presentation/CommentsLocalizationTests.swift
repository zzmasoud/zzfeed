//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZFeed

final class CommenstLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Comment"
        let bundle = Bundle(for: ImageCommentsPresenter.self)

        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
