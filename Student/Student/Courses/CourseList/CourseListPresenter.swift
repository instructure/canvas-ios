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

class CourseListPresenter {
    weak var view: CourseListViewProtocol?
    let environment: AppEnvironment
    let router: RouterProtocol

    lazy var current: Store<GetCourses> = {
        let useCase = GetCourses()
        return environment.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var past: Store<GetCourses> = {
        let useCase = GetCourses(showFavorites: true)
        return environment.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    init(env: AppEnvironment = .shared, view: CourseListViewProtocol?) {
        self.environment = env
        self.router = env.router
        self.view = view
    }

    func courseWasSelected(_ courseID: String, from controller: UIViewController) {
        router.route(to: .course(courseID), from: controller, options: nil)
    }

    func viewIsReady() {
        current.refresh()
        past.refresh()
        view?.update()
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

    func refreshRequested() {
        current.refresh(force: true)
        past.refresh(force: true)
    }

    func update() {
        view?.update()
    }
}
