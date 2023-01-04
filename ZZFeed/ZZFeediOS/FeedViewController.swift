//
//  FeedViewController.swift
//  ZZFeediOS
//
//  Created by zzmasoud on 12/31/22.
//

import UIKit
import ZZFeed

public protocol FeedItemDataLoaderTask {
    func cancel()
}

public protocol FeedItemDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedItemDataLoaderTask
}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedItemDataLoader?
    private var tasks: [IndexPath: FeedItemDataLoaderTask] = [:]

    private var feed: [FeedItem] = []
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedItemDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feed = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = feed[indexPath.row]
        
        let cell = FeedItemCell()
        cell.locationContainer.isHidden = item.location == nil
        cell.locationLabel.text = item.location
        cell.descriptionLabel.text = item.description
        cell.container.isShimmering = true
        cell.retryButton.isHidden = true
        
        let imageLoad = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: item.imageURL, completion: { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.retryButton.isHidden = image != nil
                cell?.container.isShimmering = false
            })
        }
        
        cell.onRetry = imageLoad
        imageLoad()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let item = feed[indexPath.row]
            _ = self.imageLoader?.loadImageData(from: item.imageURL, completion: { _ in })
        }
    }
}
