//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}
