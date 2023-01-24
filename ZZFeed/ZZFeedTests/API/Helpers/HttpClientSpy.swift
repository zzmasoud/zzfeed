//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation
import ZZFeed

class HttpClientSpy: HttpClient {
    private struct Task: HttpClientTask {
        let callback: () -> Void
        
        func cancel() {
            callback()
        }
    }

    private var messages = [(url: URL, completion: (HttpClient.Result)->Void)]()
    private(set) var cancelledTasks: [URL] = []

    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        messages.append((url, completion))
        let task =  Task { [weak self] in
            self?.cancelledTasks.append(url)
        }
        
        return task
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
