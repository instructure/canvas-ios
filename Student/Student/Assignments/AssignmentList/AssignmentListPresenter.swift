//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import Core

protocol AssignmentListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update()
}

class AssignmentListPresenter {

    var sort: GetAssignments.Sort
    let courseID: String
    let env: AppEnvironment
    weak var view: AssignmentListViewProtocol?

    lazy var color = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavbar()
    }

    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
        self?.updateNavbar()
    }

    lazy var assignments = env.subscribe(GetAssignments(courseID: self.courseID, sort: sort)) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: AssignmentListViewProtocol, courseID: String, sort: GetAssignments.Sort = .position) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
    }

    func viewIsReady() {
        assignments.exhaust(while: { _ in true })
        course.refresh()
        color.refresh()
        view?.update()
    }

    func update() {
        view?.update()
    }

    func updateNavbar() {
        guard let course = course.first else { return }
        view?.updateNavBar(subtitle: course.name, color: course.color)
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }
}
