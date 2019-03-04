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
    var context: Context
    let env: AppEnvironment

    lazy var courses: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: context.id)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var tabs: Store<GetContextTabs> = {
        let useCase = GetContextTabs(context: context)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    init(courseID: String, view: CourseNavigationViewProtocol, env: AppEnvironment = .shared) {
        self.context = ContextModel(.course, id: courseID)
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        courses.refresh()
        tabs.refresh()
        update()
    }

    func update() {
        view?.update()
        view?.updateNavBar(title: courses.first?.name, backgroundColor: courses.first?.color)
    }
}
