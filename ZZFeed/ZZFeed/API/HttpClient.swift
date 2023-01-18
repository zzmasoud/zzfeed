//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public protocol HttpClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result)->Void)
}
