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
    var frc: FetchedResultsController<Tab>?
    var context: Context
    var useCase: PresenterUseCase
    let queue = OperationQueue()
    lazy var loadDataFromServerOnce: () = {
        queue.addOperation(useCase)
    }()

    init(groupID: String, view: GroupNavigationViewCompositeDelegate, env: AppEnvironment = .shared) {
        self.context = ContextModel(.group, id: groupID)
        self.view = view
        useCase = GroupNavigationUseCase(context: context, env: env)

        let sort = SortDescriptor(key: #keyPath(Tab.position), ascending: true)
        let pred = NSPredicate.context(context)
        frc = env.database.fetchedResultsController(predicate: pred, sortDescriptors: [sort], sectionNameKeyPath: nil)
        frc?.delegate = self
    }

    func loadTabs() {
        _ = loadDataFromServerOnce
        do {
            try frc?.performFetch()
            view?.showTabs(frc?.fetchedObjects ?? [])
        } catch {
            view?.showError(error)
        }
    }
}

extension GroupNavigationPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        self.loadTabs()
    }
}
