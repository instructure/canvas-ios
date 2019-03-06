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

extension Assignment: ShareExtensionViewModel {
}

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

    lazy var assignments: Store<GetAssignment> = {
        let useCase = GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.submission])
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var courses: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: courseID)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

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
                showSubmitAssignmentButton(assignment: assignment, course: course)
            }
        }
    }

    func viewIsReady() {
        assignments.refresh()
        courses.refresh()
        update()
    }

    func showSubmitAssignmentButton(assignment: Assignment?, course: Course?) {
        guard let assignment = assignment, let course = course else { return }
        if assignment.canMakeSubmissions && assignment.isOpenForSubmissions() && course.enrollments?.hasRole(.student) ?? false {
            let isOnlineUpload = assignment.submissionTypes.contains(SubmissionType.online_upload)
            let submissionCount = assignment.submission?.attempt ?? 0
            let title = submissionCount > 0 ? NSLocalizedString("Resubmit Assignment", comment: "") : NSLocalizedString("Submit Assignment", comment: "")
            view?.showSubmitAssignmentButton(isEnabled: isOnlineUpload, buttonTitle: title)
        }
    }
}
