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
import CoreData

struct SubmissionAction: Equatable {
    let title: String
    let route: Route
    let options: Router.RouteOptions
}

protocol AssignmentDetailsViewProtocol: SubmissionButtonViewProtocol {
    func updateNavBar(subtitle: String?, backgroundColor: UIColor?)
    func update(assignment: Assignment, quiz: Quiz?, baseURL: URL?)
    func showSubmitAssignmentButton(title: String?)
}

class AssignmentDetailsPresenter {
    lazy var assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.submission])) { [weak self] in
        self?.update()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    lazy var courses = env.subscribe(GetCourseUseCase(courseID: courseID)) { [weak self] in
        self?.update()
    }

    var quizzes: Store<GetQuiz>?

    let env: AppEnvironment
    weak var view: AssignmentDetailsViewProtocol?
    let courseID: String
    let assignmentID: String
    var userID: String?
    let fragment: String?
    var fragmentHash: String? {
        guard let fragment = fragment, !fragment.isEmpty else { return nil }
        return "#\(fragment)"
    }
    var submissionButtonPresenter: SubmissionButtonPresenter

    var assignment: Assignment? {
        return assignments.first
    }

    lazy var fileUpload = UploadBatch(environment: env, batchID: "assignment-\(assignmentID)", callback: nil)

    init(env: AppEnvironment = .shared, view: AssignmentDetailsViewProtocol, courseID: String, assignmentID: String, fragment: String? = nil) {
        self.env = env
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.fragment = fragment
        self.submissionButtonPresenter = SubmissionButtonPresenter(env: env, view: view, assignmentID: assignmentID)
    }

    func update() {
        if quizzes?.useCase.quizID != assignment?.quizID {
            quizzes = assignment?.quizID.flatMap { quizID in env.subscribe(GetQuiz(courseID: courseID, quizID: quizID)) { [weak self] in
                self?.update()
            } }
            quizzes?.refresh()
        }
        guard let assignment = assignment, let course = courses.first else { return }
        let baseURL = fragmentHash.flatMap { URL(string: $0, relativeTo: assignment.htmlURL) } ?? assignment.htmlURL
        if let submission = assignment.submission {
            userID = submission.userID
        }
        let title = submissionButtonPresenter.buttonText(course: course, assignment: assignment, quiz: quizzes?.first)
        view?.showSubmitAssignmentButton(title: title)
        view?.updateNavBar(subtitle: course.name, backgroundColor: course.color)
        view?.update(assignment: assignment, quiz: quizzes?.first, baseURL: baseURL)
    }

    func viewIsReady() {
        colors.refresh()
        courses.refresh()
        assignments.refresh()
        fileUpload.subscribe { [weak self] _ in
            self?.update()
        }
    }

    func refresh() {
        courses.refresh(force: true)
        assignments.refresh(force: true)
        quizzes?.refresh(force: true)
    }

    func routeToSubmission(view: UIViewController) {
        guard let userID = userID else {
            return
        }
        env.router.route(to: .submission(forCourse: courseID, assignment: assignmentID, user: userID), from: view, options: nil)
    }

    func route(to url: URL, from view: UIViewController) -> Bool {
        var dest = url
        if url.path.contains("/files/") {
            dest = url.appendingQueryItems(
                URLQueryItem(name: "courseID", value: courseID),
                URLQueryItem(name: "assignmentID", value: assignmentID)
            )
        }
        env.router.route(to: dest, from: view, options: nil)
        return true
    }

    func submit(button: UIView) {
        guard let assignment = assignment else { return }
        submissionButtonPresenter.submitAssignment(assignment, button: button)
    }

    func viewFileSubmission() {
        guard let assignment = assignment else { return }
        submissionButtonPresenter.pickFiles(for: assignment)
    }
}
