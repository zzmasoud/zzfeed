//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import Combine
import ZZFeed

class LoaderSpy: FeedImageDataLoader {
    
    // MARK: - FeedLoader
    
    private var feedRequests = [PassthroughSubject<[FeedImage], Error>]()

    var loadFeedCallCount: Int { feedRequests.count }
    
    func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
        let publisher = PassthroughSubject<[FeedImage], Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    func completeFeedLoading(at index: Int, with feed: [FeedImage] = []) {
        feedRequests[index].send(feed)
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        feedRequests[index].send(completion: .failure(anyNSError()))
    }
    
    // MARK: - FeedImageDataLoader

    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }

    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.LoadResult) -> Void)]()

    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }

    private(set) var cancelledImageURLs = [URL]()

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.LoadResult) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}

