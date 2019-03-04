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

protocol AssignmentListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update()
}

class AssignmentListPresenter {
    let courseID: String
    let env: AppEnvironment
    weak var view: AssignmentListViewProtocol?

    lazy var course: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: courseID)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var assignments: Store<GetAssignments> = {
        let useCase = GetAssignments(courseID: self.courseID)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    init(env: AppEnvironment = .shared, view: AssignmentListViewProtocol, courseID: String) {
        self.courseID = courseID
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        assignments.refresh()
        course.refresh()
    }

    func update() {
        view?.update()
        loadColor()
    }

    func loadColor() {
        guard let course = course.first else { return }
        view?.updateNavBar(subtitle: course.name, color: course.color)
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }
}
