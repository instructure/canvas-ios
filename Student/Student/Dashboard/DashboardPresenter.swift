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

import UIKit
import Core

class DashboardPresenter {
    weak var view: DashboardViewProtocol?
    let environment: AppEnvironment
    let router: RouterProtocol

    lazy var groups: Store<GetUserGroups> = {
        let useCase = GetUserGroups()
        return environment.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var courses: Store<GetCourses> = {
        let useCase = GetCourses(showFavorites: true)
        return environment.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var colors: Store<GetCustomColors> = {
        let useCase = GetCustomColors()
        return environment.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    init(env: AppEnvironment = .shared, view: DashboardViewProtocol?) {
        self.environment = env
        self.router = env.router
        self.view = view
    }

    func courseWasSelected(_ courseID: String) {
        // route to details screen
    }

    func editButtonWasTapped() {
        // route to edit screen
    }

    func viewIsReady() {
        loadDataFromServer()
        update()
    }

    func pageViewStarted() {
        // log page view
    }

    func pageViewEnded() {
        // log page view
    }

    func courseOptionsWasSelected(_ courseID: String) {
        // route/modal
    }

    func groupWasSelected(_ groupID: String) {
        // route
    }

    func seeAllWasTapped() {
        // route
        if let vc = view as? UIViewController {
            router.route(to: .courses, from: vc)
        }
    }

    func refreshRequested() {
        loadDataFromServer(force: true)
    }

    func loadDataFromServer(force: Bool = false) {
        groups.refresh(force: force)
        colors.refresh(force: force)
        courses.refresh(force: force)
    }

    func update() {
        view?.updateDisplay()
    }
}
