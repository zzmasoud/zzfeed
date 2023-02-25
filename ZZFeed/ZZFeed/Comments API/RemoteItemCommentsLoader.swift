//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public final class RemoteItemCommentsLoader: RemoteLoader<[FeedItemComment]> {
    convenience public init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemCommentsMapper.map)
    }
}
