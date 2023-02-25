//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

internal struct RemoteFeedItemComment: Decodable {
    internal let id: UUID
    internal let image: URL
    internal let description: String?
    internal let location: String?
}
