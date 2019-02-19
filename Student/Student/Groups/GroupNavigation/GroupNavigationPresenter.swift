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

protocol GroupNavigationViewProtocol: ErrorViewController {
    func updateNavBar(title: String, backgroundColor: UIColor)
    func showTabs(_ tabs: [GroupNavigationViewModel], color: UIColor)
}

extension Tab: GroupNavigationViewModel {}

class GroupNavigationPresenter {
    weak var view: GroupNavigationViewProtocol?
    let frc: FetchedResultsController<Tab>
    let groupFrc: FetchedResultsController<Group>
    var context: Context
    var useCase: PresenterUseCase
    let env: AppEnvironment
    lazy var loadDataFromServerOnce: () = {
        env.queue.addOperation(useCase)
    }()

    init(groupID: String, view: GroupNavigationViewProtocol, env: AppEnvironment = .shared, useCase u: PresenterUseCase? = nil) {
        self.context = ContextModel(.group, id: groupID)
        self.env = env
        self.view = view

        if let u = u { useCase = u } else { useCase = GroupNavigationUseCase(context: context, env: env) }

        frc = env.subscribe(Tab.self, .context(context))
        groupFrc = env.subscribe(Group.self, .details(groupID))
        frc.delegate = self
        groupFrc.delegate = self
    }

    func loadTabs() {
        _ = loadDataFromServerOnce
        groupFrc.performFetch()
        var color: UIColor = .black
        if let group = groupFrc.fetchedObjects?.first {
            color = group.color
            view?.updateNavBar(title: group.name, backgroundColor: color)
        }

        frc.performFetch()
        view?.showTabs(transformToViewModels(), color: color)
    }

    func transformToViewModels() -> [GroupNavigationViewModel] {
        return frc.fetchedObjects?.compactMap { $0 } ?? []
    }
}

extension GroupNavigationPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        self.loadTabs()
    }
}
