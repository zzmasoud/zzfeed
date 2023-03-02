//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

public struct ResourceErrorViewModel {
    public let message: String?
    
    public init(message: String?) {
        self.message = message
    }
    
    public static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: .none)
    }
    
    public static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
