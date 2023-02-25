//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedItem]>

extension RemoteFeedLoader {
    convenience public init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
