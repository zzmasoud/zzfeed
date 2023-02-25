//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

internal final class ItemCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var HTTP_OK200: Int { 200 }
    
    internal static func map(data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == HTTP_OK200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteItemCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
}
