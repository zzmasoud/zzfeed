//
//  FeedViewController.swift
//  ZZFeediOS
//
//  Created by zzmasoud on 12/31/22.
//

import UIKit
import ZZFeed

public protocol FeedItemDataLoader {
    func loadImageData(from url: URL)
}

public class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedItemDataLoader?

    private var feed: [FeedItem] = []
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedItemDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        imageLoader?.loadImageData(from: item.imageURL)
        
        return cell
    }
}
