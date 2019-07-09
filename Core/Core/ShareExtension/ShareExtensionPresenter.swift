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

struct SubmissionAction: Equatable {
    var title = ""
    var route: Route?
}

public protocol ShareExtensionViewProtocol: ErrorViewController {
    func updateNavBar(backgroundColor: UIColor?)
    func update(course: Course, assignment: Assignment)
    func showSubmitAssignmentButton(isEnabled: Bool, buttonTitle: String?)
}

class ShareExtensionPresenter {
    let env: AppEnvironment
    weak var view: ShareExtensionViewProtocol?
    let courseID: String
    let assignmentID: String
    var userID: String?
    var assignment: Assignment?

    lazy var assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.submission])) { [weak self] in
        self?.update()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: ShareExtensionViewProtocol, courseID: String, assignmentID: String) {
        self.env = env
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
    }

    func update() {
        if let course = courses.first {
            view?.updateNavBar(backgroundColor: course.color)

            if let assignment = assignments.first {
                self.assignment = assignment
                if let submission = assignment.submission {
                    userID = submission.userID
                }
                view?.update(course: course, assignment: assignment)
            }
        }
    }

    func viewIsReady() {
        assignments.refresh()
        courses.refresh()
        update()
    }
}
