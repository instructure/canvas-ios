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

@objc
public protocol TableViewDataSource: NSObjectProtocol, UITableViewDataSource {
    var collectionDidChange: (Void)->Void { get set }
    var tableView: UITableView? { get set }
    func viewDidLoad(controller: UITableViewController)
    func isEmpty() -> Bool
}

extension TableViewDataSource {
    public var isEmpty: Bool {
        guard let table = tableView else {
            return true
        }

        let numberOfSections = numberOfSectionsInTableView?(table) ?? 0
        var empty = numberOfSections == 0
        if numberOfSections == 1 && tableView(table, numberOfRowsInSection: 0) == 0 {
            empty = true
        }
        return empty
    }
}

public class CollectionTableViewDataSource<C: Collection, VM: TableViewCellViewModel>: NSObject, TableViewDataSource {
    public let collection: C
    public let viewModelFactory: C.Object->VM
    public var collectionDidChange: (Void)->Void = { }
    private var disposable: Disposable?

    weak public var tableView: UITableView? {
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

        disposable = collection.collectionUpdates.observeOn(UIScheduler()).observeNext { [weak self] updates in
            self?.processUpdates(updates)
            self?.collectionDidChange()
        }.map(ScopedDisposable.init)
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

        let selectedIndexPath = tableView.indexPathForSelectedRow

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

            default:
                break
            }
        }
        tableView.endUpdates()

        tableView.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .None)
    }

    public func isEmpty() -> Bool {
        return self.isEmpty
    }
}
