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

import Foundation

import CoreData
import CanvasCore

import ReactiveSwift

class ModuleDetailDataSource<ModuleVM: TableViewCellViewModel, ModuleItemVM: TableViewCellViewModel>: NSObject, TableViewDataSource {
    let prerequisiteModulesCollection: FetchedCollection<Module>
    let itemsCollection: FetchedCollection<ModuleItem>

    var collectionDidChange: (Void) -> Void = { }

    let moduleViewModelFactory: (Module)->ModuleVM
    let itemViewModelFactory: (ModuleItem)->ModuleItemVM

    weak var tableView: UITableView? {
        didSet {
            oldValue?.dataSource = nil
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }

    fileprivate let disposable = CompositeDisposable()

    init(session: Session, courseID: String, moduleID: String, prerequisiteModuleIDs: [String], moduleViewModelFactory: @escaping (Module)->ModuleVM, itemViewModelFactory: @escaping (ModuleItem)->ModuleItemVM) throws {
        prerequisiteModulesCollection = try Module.collection(session: session, courseID: courseID, moduleIDs: prerequisiteModuleIDs)
        itemsCollection = try ModuleItem.allModuleItemsCollection(session, moduleID: moduleID)

        self.moduleViewModelFactory = moduleViewModelFactory
        self.itemViewModelFactory = itemViewModelFactory

        super.init()

        prerequisiteModulesCollection.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [weak self] updates in
                let updates = self?.correctedUpdates(from: updates, intoSection: 0) ?? []
                self?.processUpdates(updates)
            }
        itemsCollection.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [weak self] updates in
                let updates = self?.correctedUpdates(from: updates, intoSection: 1) ?? []
                self?.processUpdates(updates)
            }
    }

    deinit {
        disposable.dispose()
    }

    func correctedUpdates<CollectedType>(from updates: [CollectionUpdate<CollectedType>], intoSection section: Int) -> [CollectionUpdate<CollectedType>] {
        return updates.map { update in
            switch update {
            case .sectionInserted(_):
                return .sectionInserted(section)
            case .sectionDeleted(_):
                return .sectionDeleted(section)

            case .inserted(let ip, let m, let animated):
                return .inserted(IndexPath(row: ip.row, section: section), m, animated: animated)
            case .updated(let ip, let m, let animated):
                return .updated(IndexPath(row: ip.row, section: section), m, animated: animated)
            case .moved(let fromIp, let toIp, let m, let animated):
                return .moved(IndexPath(row: fromIp.row, section: section), IndexPath(row: toIp.row, section: section), m, animated: animated)
            case .deleted(let ip, let m, let animated):
                return .deleted(IndexPath(row: ip.row, section: section), m, animated: animated)

            case .reload: return .reload
            }
        }
    }

    func viewDidLoad(_ controller: UITableViewController) {
        ColorfulViewModel.tableViewDidLoad(controller.tableView)
        tableView = controller.tableView
    }

    func isEmpty() -> Bool {
        return self.isEmpty
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return prerequisiteModulesCollection.numberOfItemsInSection(0)
        case 1:
            return itemsCollection.numberOfItemsInSection(0)
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let indexPath = IndexPath(row: indexPath.row, section: 0)
            let item = prerequisiteModulesCollection[indexPath]
            let vm = moduleViewModelFactory(item)
            return vm.cellForTableView(tableView, indexPath: indexPath)
        case 1:
            let indexPath = IndexPath(row: indexPath.row, section: 0)
            let item = itemsCollection[indexPath]
            let vm = itemViewModelFactory(item)
            return vm.cellForTableView(tableView, indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if prerequisiteModulesCollection.isEmpty { return nil }
            return NSLocalizedString("Prerequisite Modules", comment: "Table header for prerequisite modules")
        case 1:
            return NSLocalizedString("Items", comment: "table header for module items")
        default:
            return nil
        }
    }
}
