//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit
import ZZFeed

public protocol ListViewControllerDelegate {
    func didRequestFeedRefresh()
}

public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView {
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    public var delegate: ListViewControllerDelegate?
    private var loadingControllers = [IndexPath: CellController]()

    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { (tableView, index, controller) in
            controller.dataSource.tableView(tableView, cellForRowAt: index)
        }
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)

        if #available(iOS 15.0, *) {
            dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            dataSource.apply(snapshot)
        }
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        viewModel.isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.delegate?.tableView?(tableView, didEndEditingRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath)?.dataSourcePrefetching.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath)?.dataSourcePrefetching.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController? {
        return dataSource.itemIdentifier(for: indexPath)
     }
}
