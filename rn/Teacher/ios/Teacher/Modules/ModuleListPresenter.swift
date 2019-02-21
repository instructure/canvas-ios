//
// Copyright (C) 2019-present Instructure, Inc.
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

class ModuleListPresenter {
    let env: AppEnvironment
    let courseID: String
    weak var view: ModuleListViewProtocol?

    var course: Course? {
        return courses.first
    }

    lazy var modules: Store<GetModules> = {
        let useCase = GetModules(courseID: courseID)
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reloadModules()
        }
    }()

    private lazy var courses: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: courseID)
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reloadCourse()
        }
    }()

    private lazy var colors: Store<GetCustomColors> = {
        let useCase = GetCustomColors()
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reloadCourse()
        }
    }()

    init(env: AppEnvironment, view: ModuleListViewProtocol, courseID: String) {
        self.env = env
        self.courseID = courseID
        self.view = view
    }

    func viewIsReady() {
        modules.refresh()
        courses.refresh()
        colors.refresh()
    }
}
