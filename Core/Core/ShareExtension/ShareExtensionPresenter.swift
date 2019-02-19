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
    typealias PresenterFactory = (String, String) -> PresenterUseCase

    let frc: FetchedResultsController<Assignment>
    let courseFrc: FetchedResultsController<Course>
    let env: AppEnvironment
    weak var view: ShareExtensionViewProtocol?
    var useCase: PresenterUseCase?
    let queue = OperationQueue()
    let courseID: String
    let assignmentID: String
    var userID: String?
    var assignment: Assignment?
    let useCaseFactory: PresenterFactory
    static var factory: PresenterFactory  = { (courseID: String, assignmentID: String) in
        return ShareExtensionUseCase(courseID: courseID, assignmentID: assignmentID)
    }

    init(env: AppEnvironment = .shared, view: ShareExtensionViewProtocol, courseID: String, assignmentID: String, useCaseFactory: @escaping PresenterFactory = factory) {
        self.env = env
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.useCaseFactory = useCaseFactory
        self.frc = env.subscribe(Assignment.self, .details(assignmentID))
        self.courseFrc = env.subscribe(Course.self, .details(courseID))
        self.frc.delegate = self
        self.courseFrc.delegate = self
    }

    func loadCourse() -> Course? {
        courseFrc.performFetch()
        guard let course = courseFrc.fetchedObjects?.first else { return nil }
        return course
    }

    func loadAssignment() -> Assignment? {
        frc.performFetch()
        return frc.fetchedObjects?.first
    }

    func loadData() {
        if let course = loadCourse() {
            view?.updateNavBar(backgroundColor: course.color)

            if let assignment = loadAssignment() {
                self.assignment = assignment
                if let submission = assignment.submission {
                    userID = submission.userID
                }
                view?.update(course: course, assignment: assignment)
                showSubmitAssignmentButton(assignment: assignment, course: course)
            }
        }
    }

    func loadDataFromServer() {
        let useCase = useCaseFactory(courseID, assignmentID)
        queue.addOperationWithErrorHandling(useCase, sendErrorsTo: view)
    }

    func viewIsReady() {
        loadDataFromServer()
        loadData()
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

extension ShareExtensionPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        loadData()
    }
}
