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
import CoreData

protocol GradesViewProtocol: ErrorViewController {
    func update()
}

class GradesPresenter {
    var sort: GetAssignments.Sort
    let courseID: String
    let env: AppEnvironment
    weak var view: GradesViewProtocol?
    var didFetchGroups = false

    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var assignmentGroups = env.subscribe(GetAssignmentGroups(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var assignments = env.subscribe(GetAssignmentsForGrades(courseID: self.courseID)) { [weak self] in
        self?.updateAssignmentGroups()
    }

    init(env: AppEnvironment = .shared, view: GradesViewProtocol, courseID: String, sort: GetAssignments.Sort = GetAssignments.Sort.dueAt) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
    }

    func viewIsReady() {
        assignments.refresh()
        course.refresh()
    }

    func updateAssignmentGroups() {
        if !assignments.pending && !didFetchGroups {
            didFetchGroups = true
            assignmentGroups.refresh()
        }
    }

    func update() {
        if didFetchGroups && !assignmentGroups.pending && !assignments.pending && assignments.count > 0 && assignmentGroups.count > 0 {
            view?.update()
        }
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }
}
