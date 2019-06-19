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

    lazy var assignments: Store<GetAssignments> = env.subscribe(GetAssignments(courseID: courseID)) { [weak self] in
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
