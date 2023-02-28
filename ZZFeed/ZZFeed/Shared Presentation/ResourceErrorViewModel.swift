//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

public struct ResourceErrorViewModel {
    public let message: String?
    
    public static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: .none)
    }
    
    public static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
