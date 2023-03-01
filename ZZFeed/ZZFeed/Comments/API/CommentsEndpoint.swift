//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public enum CommentEndpoint {
    case get(UUID)

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get(let imageId):
            return baseURL
                .appendingPathComponent("/v1/image")
                .appendingPathComponent(imageId.uuidString)
                .appendingPathComponent("comments")
        }
    }
}
