//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Core

protocol AssignmentsView: class {
    func update()
}

class AssignmentsPresenter {
    let env: AppEnvironment
    let courseID: String
    let selectedAssignmentID: String?
    let callback: (Assignment) -> Void
    weak var view: AssignmentsView?

    lazy var assignments = env.subscribe(GetSubmittableAssignments(courseID: courseID)) { [weak self] in
        self?.view?.update()
    }

    init(environment: AppEnvironment, courseID: String, selectedAssignmentID: String?, callback: @escaping (Assignment) -> Void) {
        self.env = environment
        self.courseID = courseID
        self.selectedAssignmentID = selectedAssignmentID
        self.callback = callback
    }

    func viewIsReady() {
        assignments.refresh(force: true)
    }

    func selectAssignment(at indexPath: IndexPath) {
        if let assignment = assignments[indexPath] {
            callback(assignment)
        }
    }

    func getNextPage() {
        assignments.getNextPage()
    }
}
