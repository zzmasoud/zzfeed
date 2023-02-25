//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public typealias RemoteItemCommentsLoader = RemoteLoader<[FeedItemComment]>

extension RemoteItemCommentsLoader {
    convenience public init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemCommentsMapper.map)
    }
}
