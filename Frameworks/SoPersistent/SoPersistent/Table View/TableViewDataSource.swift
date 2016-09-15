//
//  TableViewDataSource.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 3/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

@objc
public protocol TableViewDataSource: NSObjectProtocol, UITableViewDataSource {
    var collectionDidChange: (Void)->Void { get set }
    func viewDidLoad(controller: UITableViewController)
    func isEmpty() -> Bool
}

public class CollectionTableViewDataSource<C: Collection, VM: TableViewCellViewModel>: NSObject, TableViewDataSource {

    public let collection: C
    public let viewModelFactory: C.Object->VM
    public var collectionDidChange: (Void)->Void = { }

    weak var tableView: UITableView? {
        didSet {
            oldValue?.dataSource = nil
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }

    public init(collection: C, viewModelFactory: C.Object -> VM) {
        self.collection = collection
        self.viewModelFactory = viewModelFactory
        super.init()

        collection.collectionUpdated = { [weak self] updates in
            self?.processUpdates(updates)
            self?.collectionDidChange()
        }
    }

    public func viewDidLoad(controller: UITableViewController) {
        VM.tableViewDidLoad(controller.tableView)
        tableView = controller.tableView
    }

    // MARK: UITableViewDataSource

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return collection.numberOfSections()
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.numberOfItemsInSection(section)
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = collection[indexPath]
        let vm = viewModelFactory(item)
        return vm.cellForTableView(tableView, indexPath: indexPath)
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collection.titleForSection(section)
    }

    func processUpdates(updates: [CollectionUpdate<C.Object>]) {
        guard let tableView = tableView else { return }

        if updates == [.Reload] {
            tableView.reloadData()
            return
        }

        tableView.beginUpdates()
        for update in updates {
            switch update {

            case .SectionInserted(let s):
                tableView.insertSections(NSIndexSet(index: s), withRowAnimation: .Automatic)

            case .SectionDeleted(let s):
                tableView.deleteSections(NSIndexSet(index: s), withRowAnimation: .Automatic)

            case .Inserted(let indexPath, _):
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

            case .Updated(let indexPath, _):
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

            case let .Moved(from, to, _):
                tableView.deleteRowsAtIndexPaths([from], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([to], withRowAnimation: .Fade)

            case .Deleted(let indexPath, _):
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

            case .Reload:
                tableView.reloadData()
            }
        }
        tableView.endUpdates()
    }

    public func isEmpty() -> Bool {
        guard let table = tableView else {
            return true
        }

        var empty = numberOfSectionsInTableView(table) == 0
        if numberOfSectionsInTableView(table) == 1 && tableView(table, numberOfRowsInSection: 0) == 0 {
            empty = true
        }
        return empty
    }
}