
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
import ReactiveCocoa
import CoreData
import SoLazy
import Result

public protocol TableViewCellViewModel {
    static func tableViewDidLoad(tableView: UITableView)
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
}

public class TableViewController: UITableViewController {
    public static var defaultErrorHandler: (UIViewController, NSError) -> () = { viewController, error in
        error.presentAlertFromViewController(viewController)
    }

    public var dataSource: TableViewDataSource? {
        didSet {
            if isViewLoaded() {
                dataSource?.viewDidLoad(self)
            }

            dataSource?.collectionDidChange = { [weak self] in
                self?.updateEmptyView()
            }
        }
    }

    public var refresher: Refresher? {
        didSet {
            if oldValue !== refresher {
                oldValue?.refreshControl.endRefreshing()
                oldValue?.refreshControl.removeFromSuperview()
                refresher?.makeRefreshable(self)
                setupRefreshingObservation()
            }
        }
    }

    public var didSelectItemAtIndexPath: (NSIndexPath->())? = nil

    public var emptyView: UIView? {
        didSet {
            self.updateEmptyView()
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public init(dataSource: TableViewDataSource, refresher: Refresher? = nil) {
        self.dataSource = dataSource
        self.refresher = refresher
        super.init(nibName: nil, bundle: nil)
        setupRefreshingObservation()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupRefreshingObservation() {
        refresher?.refreshingBegan.observeNext { [weak self] in
            self?.updateEmptyView()
        }
        refresher?.refreshingCompleted.observeNext { [weak self] error in
            self?.updateEmptyView()
            if let error = error {
                self?.handleError(error)
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        dataSource?.viewDidLoad(self)
        refresher?.makeRefreshable(self)
        updateEmptyView()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresher?.refresh(false)
    }

    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelectItemAtIndexPath?(indexPath)
    }

    // MARK: Empty View Handling
    private func updateEmptyView() {
        guard let emptyView = emptyView, dataSource = dataSource else {
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
    public func handleError(error: NSError) {
        TableViewController.defaultErrorHandler(self, error)
    }
}
