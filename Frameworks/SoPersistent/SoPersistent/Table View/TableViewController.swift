//
//  TableViewController.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/29/15.
//  Copyright © 2015 Instructure. All rights reserved.
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
            oldValue?.refreshControl.endRefreshing()
            oldValue?.refreshControl.removeFromSuperview()
            refresher?.makeRefreshable(self)
            setupRefreshingObservation()
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
