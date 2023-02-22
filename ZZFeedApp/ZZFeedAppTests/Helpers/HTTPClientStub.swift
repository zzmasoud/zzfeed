//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import ZZFeed

class HTTPClientStub: HttpClient {
    private class Task: HttpClientTask {
        func cancel() {}
    }
    
    private let stub: (URL) -> HttpClient.Result
    
    init(stub: @escaping (URL) -> HttpClient.Result) {
        self.stub = stub
    }
    
    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        completion(stub(url))
        return Task()
    }
}

extension HTTPClientStub {
    static var offline: HTTPClientStub {
        HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
    }
    
    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }
}
