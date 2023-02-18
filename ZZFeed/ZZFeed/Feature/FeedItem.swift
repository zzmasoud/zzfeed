//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public struct FeedItem: Hashable {
    public let id: UUID
    public let imageURL: URL
    public let description: String?
    public let location: String?
    
    public init(id: UUID = UUID(), description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.imageURL = imageURL
        self.description = description
        self.location = location
    }
}
