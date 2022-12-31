//
//  FeedViewController.swift
//  ZZFeediOS
//
//  Created by Masoud Sheikh Hosseini on 12/31/22.
//

import UIKit
import ZZFeed

public class FeedViewController: UITableViewController {
    private var loader: Feedloader?
    
    public convenience init(loader: Feedloader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
