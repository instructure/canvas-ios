//
// Copyright (C) 2018-present Instructure, Inc.
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
import Core

protocol GroupNavigationViewProtocol: class {
    func showTabs(_ tabs: [Tab])
}

typealias GroupNavigationViewCompositeDelegate = GroupNavigationViewProtocol & ErrorViewController

class GroupNavigationPresenter {
    weak var view: GroupNavigationViewCompositeDelegate?
    var persistence: Persistence
    var frc: FetchedResultsController<Tab>?

    init(persistence: Persistence = RealmPersistence.main) {
        self.persistence = persistence
        let sort = SortDescriptor(key: #keyPath(Tab.position), ascending: true)
        frc = persistence.fetchedResultsController(predicate: NSPredicate.all, sortDescriptors: [sort], sectionNameKeyPath: nil)
    }

    func loadTabs() {
        do {
            try frc?.performFetch()
            view?.showTabs(frc?.fetchedObjects ?? [])
        } catch {
            view?.showError(error)
        }
    }
}
