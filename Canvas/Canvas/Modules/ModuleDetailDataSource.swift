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
import SoPersistent
import CoreData
import SoEdventurous
import TooLegit
import ReactiveCocoa

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

    private let disposable = CompositeDisposable()

    init(session: Session, courseID: String, moduleID: String, prerequisiteModuleIDs: [String], moduleViewModelFactory: (Module)->ModuleVM, itemViewModelFactory: (ModuleItem)->ModuleItemVM) throws {
        prerequisiteModulesCollection = try Module.collection(session, courseID: courseID, moduleIDs: prerequisiteModuleIDs)
        itemsCollection = try ModuleItem.allModuleItemsCollection(session, moduleID: moduleID)

        self.moduleViewModelFactory = moduleViewModelFactory
        self.itemViewModelFactory = itemViewModelFactory

        super.init()

        prerequisiteModulesCollection.collectionUpdates
            .observeOn(UIScheduler())
            .observeNext { [weak self] updates in
                self?.processUpdates(updates, inSection: 0)
            }
        itemsCollection.collectionUpdates
            .observeOn(UIScheduler())
            .observeNext { [weak self] updates in
                self?.processUpdates(updates, inSection: 1)
            }
    }

    deinit {
        disposable.dispose()
    }

    func viewDidLoad(controller: UITableViewController) {
        ColorfulViewModel.tableViewDidLoad(controller.tableView)
        tableView = controller.tableView
    }

    func isEmpty() -> Bool {
        return self.isEmpty
    }

    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return prerequisiteModulesCollection.numberOfItemsInSection(0)
        case 1:
            return itemsCollection.numberOfItemsInSection(0)
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let indexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            let item = prerequisiteModulesCollection[indexPath]
            let vm = moduleViewModelFactory(item)
            return vm.cellForTableView(tableView, indexPath: indexPath)
        case 1:
            let indexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            let item = itemsCollection[indexPath]
            let vm = itemViewModelFactory(item)
            return vm.cellForTableView(tableView, indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }

    func processUpdates<T>(updates: [CollectionUpdate<T>], inSection section: Int) {
        guard let tableView = tableView else { return }

        if updates == [.Reload] {
            tableView.reloadData()
            return
        }

        tableView.beginUpdates()
        for update in updates {
            switch update {

            case .SectionInserted:
                tableView.insertSections(NSIndexSet(index: section), withRowAnimation: .Automatic)

            case .SectionDeleted:
                tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: .Automatic)

            case .Inserted(let indexPath, _):
                let indexPath = NSIndexPath(forRow: indexPath.row, inSection: section)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

            case .Updated(let indexPath, _):
                let indexPath = NSIndexPath(forRow: indexPath.row, inSection: section)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

            case let .Moved(from, to, _):
                let from = NSIndexPath(forRow: from.row, inSection: section)
                let to = NSIndexPath(forRow: to.row, inSection: section)
                tableView.deleteRowsAtIndexPaths([from], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([to], withRowAnimation: .Fade)

            case .Deleted(let indexPath, _):
                let indexPath = NSIndexPath(forRow: indexPath.row, inSection: section)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

            case .Reload:
                tableView.reloadData()
            }
        }
        tableView.endUpdates()
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
