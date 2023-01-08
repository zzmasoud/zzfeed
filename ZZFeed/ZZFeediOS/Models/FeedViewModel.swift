//
//  FeedViewModel.swift
//  ZZFeediOS
//
//  Created by Masoud on 08.01.23.
//

import ZZFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingChange: ((Bool) -> Void)?
    var onLoad: (([FeedItem]) -> Void)?
    
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
