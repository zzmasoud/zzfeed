//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

public class URLSessionHTTPClient: HttpClient {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
        let task =  session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        task.resume()
        
        return URLSessionTaskWrapper(wrapped: task)
    }
    
    private struct URLSessionTaskWrapper: HttpClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
}
