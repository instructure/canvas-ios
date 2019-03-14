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

extension Assignment: AssignmentDetailsViewModel {
    public var viewableScore: Double? {
        return submission?.score
    }
    public var viewableGrade: String? {
        return submission?.grade
    }
}

struct SubmissionAction: Equatable {
    let title: String
    let route: Route
    let options: Router.RouteOptions
}

protocol AssignmentDetailsViewProtocol: ErrorViewController {
    func updateNavBar(subtitle: String?, backgroundColor: UIColor?)
    func update(assignment: AssignmentDetailsViewModel, baseURL: URL?)
    func showSubmitAssignmentButton(title: String?)
    func chooseSubmissionType(_ types: [SubmissionType])
}

class AssignmentDetailsPresenter {
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

    let supportedSubmissionTypes: [SubmissionType] = [
        .online_upload,
        .online_url,
    ]

    init(env: AppEnvironment = .shared, view: AssignmentDetailsViewProtocol, courseID: String, assignmentID: String, fragment: String? = nil) {
        self.env = env
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.fragment = fragment
    }

    func update() {
        guard let assignment = assignments.first, let course = courses.first else { return }
        let baseURL = fragmentHash.flatMap { URL(string: $0, relativeTo: assignment.htmlURL) } ?? assignment.htmlURL
        if let submission = assignment.submission {
            userID = submission.userID
        }
        showSubmitAssignmentButton(assignment: assignment, course: course)
        view?.updateNavBar(subtitle: course.name, backgroundColor: course.color)
        view?.update(assignment: assignment, baseURL: baseURL)

    }

    func viewIsReady() {
        courses.refresh()
        assignments.refresh()
    }

    func refresh() {
        courses.refresh(force: true)
        assignments.refresh(force: true)
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

    func showSubmitAssignmentButton(assignment: Assignment?, course: Course?) {
        guard let assignment = assignment, let course = course else { return }
        if assignment.canMakeSubmissions && assignment.isOpenForSubmissions() && course.enrollments?.hasRole(.student) ?? false {
            let title = assignment.submission?.workflowState == .unsubmitted
                ? NSLocalizedString("Submit Assignment", comment: "")
                : NSLocalizedString("Resubmit Assignment", comment: "")

            view?.showSubmitAssignmentButton(title: title)
        } else {
            view?.showSubmitAssignmentButton(title: nil)
        }
    }

    func viewFileSubmission(from viewController: UIViewController) {
        env.router.route(to: Route.assignmentFileUpload(courseID: courseID, assignmentID: assignmentID), from: viewController, options: [.modal, .embedInNav])
    }

    func submitAssignment(from viewController: UIViewController) {
        guard let assignment = assignments.first, assignment.canMakeSubmissions else {
            return
        }
        let supported = assignment.submissionTypes.filter { supportedSubmissionTypes.contains($0) }
        if supported.count == 1, let type = supported.first {
            submit(type, from: viewController)
            return
        }
        view?.chooseSubmissionType(supported)
    }

    func submit(_ type: SubmissionType, from viewController: UIViewController) {
        switch type {
        case .online_upload:
            let route = Route.assignmentFileUpload(courseID: courseID, assignmentID: assignmentID)
            env.router.route(to: route, from: viewController, options: [.modal, .embedInNav])
        case .online_url:
            let route = Route.assignmentUrlSubmission(courseID: courseID, assignmentID: assignmentID, userID: userID ?? "")
            env.router.route(to: route, from: viewController, options: [.modal, .embedInNav])
        default:
            break
        }
    }
}
