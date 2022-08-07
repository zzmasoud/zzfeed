//
//  URLSessionHttpClientTest.swift
//  ZZFeedTests
//
//  Created by Masoud on 5/8/22.
//

import XCTest
import ZZFeed

class URLSessionHttpClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHttpClientTest: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = URL(string: "http://foo.bar")!

        let exp = expectation(description: "wait for completion")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        URLSessionHttpClient().get(from: url) { _ in
            
        }

        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://foo.bar")!
        let error = NSError(domain: "Request Error", code: 1)
        URLProtocolStub.stub(url: url, error: error)
        
        let sut = URLSessionHttpClient()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error: \(error), got: \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let error: Error?
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            requestObserver = nil
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            requestObserver?(request)
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
