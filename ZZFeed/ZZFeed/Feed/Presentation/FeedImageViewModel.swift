//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

public struct FeedItemViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
