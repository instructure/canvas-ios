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
    let frc: FetchedResultsController<Assignment>
    let courseFrc: FetchedResultsController<Course>
    let fileSubmissionFrc: FetchedResultsController<FileSubmission>
    let env: AppEnvironment
    weak var view: AssignmentDetailsViewProtocol?
    let courseID: String
    let assignmentID: String
    var userID: String?
    var assignment: Assignment?
    let fragment: String?
    let useCaseFactory: UseCaseFactory
    var fragmentHash: String? {
        guard let fragment = fragment, !fragment.isEmpty else { return nil }
        return "#\(fragment)"
    }

    let supportedSubmissionTypes: [SubmissionType] = [
        .online_upload,
        .online_url,
    ]

    init(env: AppEnvironment = .shared, view: AssignmentDetailsViewProtocol, courseID: String, assignmentID: String, fragment: String? = nil, useCaseFactory factory: UseCaseFactory? = nil) {
        self.env = env
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.fragment = fragment
        self.frc = env.subscribe(Assignment.self, .details(assignmentID))
        self.courseFrc = env.subscribe(Course.self, .details(courseID))
        self.fileSubmissionFrc = env.subscribe(FileSubmission.self, .assignment(assignmentID))
        self.useCaseFactory = factory ?? { _ in AssignmentDetailsUseCase(courseID: courseID, assignmentID: assignmentID) }

        frc.delegate = self
        courseFrc.delegate = self
        fileSubmissionFrc.delegate = self
    }

    func loadCourse() -> Course? {
        return courseFrc.fetchedObjects?.first
    }

    func loadAssignment() -> Assignment? {
        return frc.fetchedObjects?.first
    }

    func loadData() {
        let course = loadCourse()
        view?.updateNavBar(subtitle: course?.name, backgroundColor: course?.color)

        if let assignment = loadAssignment() {
            self.assignment = assignment
            let baseURL = fragmentHash.flatMap { URL(string: $0, relativeTo: assignment.htmlURL) } ?? assignment.htmlURL
            if let submission = assignment.submission {
                userID = submission.userID
            }
            view?.update(assignment: assignment, baseURL: baseURL)
            showSubmitAssignmentButton(assignment: assignment, course: course)
        }
    }

    func loadDataFromServer() {
        let useCase = useCaseFactory(false)
        env.queue.addOperationWithErrorHandling(useCase, sendErrorsTo: view)
    }

    func viewIsReady() {
        courseFrc.performFetch()
        frc.performFetch()
        fileSubmissionFrc.performFetch()
        loadDataFromServer()
        loadData()
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
            let submissionCount = assignment.submission?.attempt ?? 0
            let title = submissionCount > 0 ? NSLocalizedString("Resubmit Assignment", comment: "") : NSLocalizedString("Submit Assignment", comment: "")
            view?.showSubmitAssignmentButton(title: title)
        } else {
            view?.showSubmitAssignmentButton(title: nil)
        }
    }

    func viewFileSubmission(from viewController: UIViewController) {
        env.router.route(to: Route.assignmentFileUpload(courseID: courseID, assignmentID: assignmentID), from: viewController, options: [.modal, .embedInNav])
    }

    func submitAssignment(from viewController: UIViewController) {
        guard let assignment = assignment, assignment.canMakeSubmissions else {
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
            let cancelPrevious = CancelFileSubmission(database: env.database, assignmentID: assignmentID)
            env.queue.addOperation(cancelPrevious) { [weak self, weak viewController] error in
                if let error = error {
                    self?.view?.showError(error)
                }
                if let vc = viewController {
                    self?.env.router.route(to: route, from: vc, options: [.modal, .embedInNav])
                }
            }
        case .online_url:
            let route = Route.assignmentUrlSubmission(courseID: courseID, assignmentID: assignmentID, userID: userID ?? "")
            env.router.route(to: route, from: viewController, options: [.modal, .embedInNav])
        default:
            break
        }
    }
}

extension AssignmentDetailsPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        loadData()
    }
}
