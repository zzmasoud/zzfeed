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
    private var feedRefreshController: FeedRefreshViewController?
    private var imageLoader: FeedItemDataLoader?
    private var cellControllers = [IndexPath: FeedItemCellController]()

    private var feed: [FeedItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    public convenience init(feedRefreshController: FeedRefreshViewController, imageLoader: FeedItemDataLoader) {
        self.init()
        self.feedRefreshController = feedRefreshController
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = feedRefreshController?.view
        feedRefreshController?.onRefresh = { [weak self] feed in
            self?.feed = feed
        }
        
        tableView.prefetchDataSource = self
        feedRefreshController?.refresh()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)

    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedItemCellController {
         let cellModel = feed[indexPath.row]
         let cellController = FeedItemCellController(model: cellModel, imageLoader: imageLoader!)
         cellControllers[indexPath] = cellController
         return cellController
     }

    
    private func removeCellController(forRowAt indexPath: IndexPath) {
         cellControllers[indexPath] = nil
     }
}
