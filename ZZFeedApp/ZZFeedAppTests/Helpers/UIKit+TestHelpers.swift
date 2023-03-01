//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit

// MARK: - UIButton + Simulate

extension UIButton {
    func simulateTap() {
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({ selector in
                (target as NSObject).perform(Selector(selector))
            })
        })
    }
}

// MARK: - UIRefreshControl + Simulate

extension UIRefreshControl {
    func simulatePullToRefresh() {
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ selector in
                (target as NSObject).perform(Selector(selector))
            })
        })
    }
}

// MARK: - UIView + RunLoop

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

