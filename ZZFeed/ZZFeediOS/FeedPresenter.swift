//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import ZZFeed

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedItem])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var feedLoadingView: FeedLoadingView?

    func loadFeed() {
        feedLoadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.feedLoadingView?.display(isLoading: false)
        }
    }
}
