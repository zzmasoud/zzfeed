//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        let cell = self.dequeueReusableCell(withIdentifier: identifier) as! T
        return cell
    }
}

