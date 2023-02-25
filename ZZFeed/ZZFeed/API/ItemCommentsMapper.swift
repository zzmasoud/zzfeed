//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

internal final class ItemCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    internal static func map(data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard isOK(response),
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteItemCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        return (200..<300).contains(response.statusCode)
    }
}
