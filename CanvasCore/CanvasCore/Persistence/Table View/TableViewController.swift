//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
