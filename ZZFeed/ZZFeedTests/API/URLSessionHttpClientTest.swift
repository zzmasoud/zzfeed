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
    
    struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
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
    
    override func tearDown() {
        URLProtocolStub.requestObserver = nil
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = makeAnyURL()

        let exp = expectation(description: "wait for completion")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in
            
        }

        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "Request Error", code: 1)
        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as? NSError
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        let nonHTTPURLResponse = URLResponse(url: makeAnyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyHTTPURLResponse = HTTPURLResponse(url: makeAnyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let anyData = Data()
        let anyError = NSError(domain: "Any Error", code: 1)
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = Data()
        let anyHTTPURLResponse = HTTPURLResponse(url: makeAnyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.stub(url: makeAnyURL(), data: data, response: anyHTTPURLResponse, error: nil)
        
        let exp = expectation(description: "wait for completion...")
        makeSUT().get(from: makeAnyURL()) { result in
            switch result {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse, anyHTTPURLResponse)
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }

    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeAnyURL() -> URL {
        return URL(string: "http://foo.bar")!
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let url = makeAnyURL()
        let sut = makeSUT(file: file, line: line)
        URLProtocolStub.stub(url: url, error: error)
                
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.get(from: url) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected error, got: \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Memory leak alert!", file: file, line: line)
        }
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: HTTPURLResponse?
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(url: URL, data: Data? = nil, response: HTTPURLResponse? = nil, error: Error? = nil) {
            stubs[url] = Stub(error: error, data: data, response: response)
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
