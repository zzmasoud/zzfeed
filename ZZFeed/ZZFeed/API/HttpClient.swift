//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public protocol HttpClientTask {
    func cancel()
}

public protocol HttpClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
        
    @discardableResult
    func get(from url: URL, completion: @escaping (Result)->Void) -> HttpClientTask
}
