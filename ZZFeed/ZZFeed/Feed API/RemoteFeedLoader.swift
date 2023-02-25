//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public final class RemoteFeedLoader: RemoteLoader<[FeedItem]> {
    convenience public init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
