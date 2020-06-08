//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import ReactiveSwift

@objc
public protocol TableViewDataSource: UITableViewDataSource {
    var collectionDidChange: ()->Void { get set }
    var tableView: UITableView? { get set }
    func viewDidLoad(_ controller: UITableViewController)
    func isEmpty() -> Bool
}

extension TableViewDataSource {
    public var isEmpty: Bool {
        guard let table = tableView else {
            return true
        }

        let sectionCount = numberOfSections?(in: table) ?? 0
        var empty = sectionCount == 0
        if sectionCount == 1 && tableView(table, numberOfRowsInSection: 0) == 0 {
            empty = true
        }
        return empty
    }

    public func processUpdates<CollectedType>(_ updates: [CollectionUpdate<CollectedType>]) {
        guard let tableView = tableView else { return }
        let selectedIndexPath = tableView.indexPathForSelectedRow
        defer {
            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
        }

        if updates == [.reload] {
            tableView.reloadData()
            return
        }

        tableView.beginUpdates()
        for update in updates {
            switch update {

            case .sectionInserted(let s):
                tableView.insertSections(IndexSet(integer: s), with: .automatic)

            case .sectionDeleted(let s):
                tableView.deleteSections(IndexSet(integer: s), with: .automatic)

            case .inserted(let indexPath, _, let animated):
                tableView.insertRows(at: [indexPath], with: animated ? .automatic : .none)

            case .updated(let indexPath, _, let animated):
                tableView.reloadRows(at: [indexPath], with: animated ? .automatic : .none)

            case let .moved(from, to, _, animated):
                tableView.deleteRows(at: [from], with: animated ? .fade : .none)
                tableView.insertRows(at: [to], with: animated ? .fade : .none)

            case .deleted(let indexPath, _, let animated):
                tableView.deleteRows(at: [indexPath], with: animated ? .automatic : .none)

            default:
                break
            }
        }
        tableView.endUpdates()
    }
}

open class CollectionTableViewDataSource<C: Collection, VM: TableViewCellViewModel>: NSObject, TableViewDataSource {
    public let collection: C
    public let viewModelFactory: (C.Object)->VM
    open var collectionDidChange: ()->Void = { }
    fileprivate var disposable: Disposable?

    weak open var tableView: UITableView? {
        didSet {
            oldValue?.dataSource = nil
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }

    public init(collection: C, viewModelFactory: @escaping (C.Object) -> VM) {
        self.collection = collection
        self.viewModelFactory = viewModelFactory
        super.init()

        disposable = collection.collectionUpdates.observe(on: UIScheduler()).observeValues { [weak self] updates in
            self?.processUpdates(updates)
            self?.collectionDidChange()
        }.map(ScopedDisposable.init)
    }

    open func viewDidLoad(_ controller: UITableViewController) {
        VM.tableViewDidLoad(controller.tableView)
        tableView = controller.tableView
    }

    // MARK: UITableViewDataSource

    open func numberOfSections(in tableView: UITableView) -> Int {
        return collection.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.numberOfItemsInSection(section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = collection[indexPath]
        let vm = viewModelFactory(item)
        return vm.cellForTableView(tableView, indexPath: indexPath)
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collection.titleForSection(section)
    }

    open func isEmpty() -> Bool {
        return self.isEmpty
    }
}

extension CollectionTableViewDataSource where C.Object == VM {
    public convenience init(collection: C) {
        self.init(collection: collection, viewModelFactory: { $0 })
    }
}
