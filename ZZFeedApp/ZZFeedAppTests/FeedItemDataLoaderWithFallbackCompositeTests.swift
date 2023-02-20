//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZFeed

class FeedItemDataLoaderWithFallbackComposite: FeedItemDataLoader {
    private let primary: FeedItemDataLoader
    private let fallback: FeedItemDataLoader
    
    init(primary: FeedItemDataLoader, fallback: FeedItemDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedItemDataLoaderTask {
        var task = primary.loadImageData(from: url, completion: completion)
        return task
    }
}

class FeedItemDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryItemDataOnPrimaryLoaderSuccess() {
        let primaryData = primaryData()
        let fallbackData = fallbackData()
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteWith: .success(primaryData))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedItemDataLoader.LoadResult, fallbackResult: FeedItemDataLoader.LoadResult, file: StaticString = #file, line: UInt = #line) -> FeedItemDataLoader {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedItemDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func expect(_ sut: FeedItemDataLoader, toCompleteWith expectedResult: FeedItemDataLoader.LoadResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion...")
        _ = sut.loadImageData(from: anyURL()) { result in
            switch (result, expectedResult) {
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)
                
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as NSError, expectedError as NSError, file: file, line: line)
                
            default:
                XCTFail("expected to get \(expectedResult) but got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func primaryData() -> Data {
        return Data("primary data".utf8)
    }
    
    private func fallbackData() -> Data {
        return Data("primary data".utf8)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://u.rl")!
    }
    
    private class LoaderStub: FeedItemDataLoader {
        private struct Task: FeedItemDataLoaderTask {
            func cancel() {}
        }
        
        private let result: FeedItemDataLoader.LoadResult
        
        init(result: FeedItemDataLoader.LoadResult) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedItemDataLoaderTask {
            completion(result)
            return Task()
        }
    }
}
