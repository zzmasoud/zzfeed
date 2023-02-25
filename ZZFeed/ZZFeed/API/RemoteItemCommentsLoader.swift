//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public class RemoteItemCommentsLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[FeedItemComment], Error>

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(Self.map(data, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemCommentsMapper.map(data: data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error as! RemoteItemCommentsLoader.Error)
        }
    }
}

private extension Array where Element == FeedItemComment {
    func toModels() -> [FeedItemComment] {
        return map { FeedItemComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, username: $0.username) }
    }
}
