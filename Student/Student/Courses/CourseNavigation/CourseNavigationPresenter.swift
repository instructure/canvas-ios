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

extension Tab: CourseNavigationViewModel {}

class CourseNavigationPresenter {
    weak var view: CourseNavigationViewProtocol?
    let frc: FetchedResultsController<Tab>
    var context: Context
    let useCase: PresenterUseCase
    let env: AppEnvironment
    lazy var loadDataFromServerOnce: () = {
        env.queue.addOperation(useCase)
    }()

    init(courseID: String, view: CourseNavigationViewProtocol, env: AppEnvironment = .shared, useCase u: PresenterUseCase? = nil) {
        self.context = ContextModel(.course, id: courseID)
        self.env = env
        self.view = view

        if let u = u { useCase = u } else { useCase = CourseNavigationUseCase(context: context, env: env) }

        frc = env.subscribe(Tab.self, .context(context))
        frc.delegate = self
    }

    func loadTabs() {
        _ = loadDataFromServerOnce
        frc.performFetch()
        view?.showTabs(transformToViewModels())
    }

    func transformToViewModels() -> [CourseNavigationViewModel] {
        return frc.fetchedObjects?.compactMap { $0 } ?? []
    }
}

extension CourseNavigationPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        self.loadTabs()
    }
}
