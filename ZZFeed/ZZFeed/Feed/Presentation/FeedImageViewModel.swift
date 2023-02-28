//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

public struct FeedItemViewModel {
    public let description: String?
    public let location: String?
    
    public init(description: String? = nil, location: String? = nil) {
        self.description = description
        self.location = location
    }
    
    public var hasLocation: Bool {
        return location != nil
    }
}
