//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit
import ReactiveSwift
import CoreData

import Result

public protocol TableViewCellViewModel {
    static func tableViewDidLoad(_ tableView: UITableView)
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
}

open class TableViewController: UITableViewController {
    open var dataSource: TableViewDataSource? {
        didSet {
            if isViewLoaded {
                dataSource?.viewDidLoad(self)
            }

            dataSource?.collectionDidChange = { [weak self] in
                self?.updateEmptyView()
            }
        }
    }

    open var refresher: Refresher? {
        didSet {
            if oldValue !== refresher {
                oldValue?.refreshControl.endRefreshing()
                oldValue?.refreshControl.removeFromSuperview()
                refresher?.makeRefreshable(self)
                setupRefreshingObservation()
            }
        }
    }
    
    private var refreshDisposable: Disposable? = nil

    open var didSelectItemAtIndexPath: ((IndexPath)->())? = nil

    open var emptyView: UIView? {
        didSet {
            self.updateEmptyView()
        }
    }

    public init() {
        super.init(style: .plain)
    }
    
    deinit {
        refreshDisposable?.dispose()
    }

    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    public init(dataSource: TableViewDataSource, refresher: Refresher? = nil, style: UITableViewStyle = .plain) {
        self.dataSource = dataSource
        self.refresher = refresher
        super.init(style: style)
        setupRefreshingObservation()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate func setupRefreshingObservation() {
        refreshDisposable?.dispose()
        let composite = CompositeDisposable()
        refreshDisposable = composite
        
        composite += refresher?.refreshingBegan.observeValues { [weak self] in
            self?.updateEmptyView()
        }
        composite += refresher?.refreshingCompleted.observeValues { [weak self] error in
            self?.updateEmptyView()
            if let error = error {
                self?.handleError(error)
            }
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        dataSource?.viewDidLoad(self)
        refresher?.makeRefreshable(self)
        updateEmptyView()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresher?.refresh(false)
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectItemAtIndexPath?(indexPath)
    }

    // MARK: Empty View Handling
    fileprivate func updateEmptyView() {
        guard let emptyView = emptyView, let dataSource = dataSource else {
            return
        }

        let isRefreshing = refresher?.isRefreshing ?? false
        let emptyVisible = dataSource.isEmpty() && !isRefreshing
        if emptyVisible {
            tableView.tableFooterView = UIView()
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = UIView()
        }
    }

    // MARK: Error Handling

    /** Presents an alert via NSError+SoLazy.swift

     Override if you wish to handle the error yourself
     */
    open func handleError(_ error: NSError) {
        ErrorReporter.reportError(error, from: self)
    }
}
