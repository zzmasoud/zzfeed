//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  
import ZZFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingChange: Observer<Bool>?
    var onLoad: Observer<[FeedItem]>?
    
    func loadFeed() {
        onLoadingChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onLoad?(feed)
            }
            self?.onLoadingChange?(false)
        }
    }
}
