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

extension Assignment: SubmissionDetailsViewAssignmentModel {}
extension Submission: SubmissionDetailsViewModel {}

class SubmissionDetailsPresenter {
    typealias PresenterFactory = (Bool) -> PresenterUseCase

    let context: Context
    let assignmentID: String
    let userID: String
    let env: AppEnvironment
    weak var view: SubmissionDetailsViewProtocol?

    let useCaseFactory: PresenterFactory

    let submissionFrc: FetchedResultsController<Submission>
    let assignmentFrc: FetchedResultsController<Assignment>
    let courseFrc: FetchedResultsController<Course>

    var selectedAttempt: Int = 0
    var contentSubmission: Submission?

    init(env: AppEnvironment = .shared, view: SubmissionDetailsViewProtocol, context: Context,
         assignmentID: String, userID: String, useCaseFactory: PresenterFactory? = nil) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        self.env = env
        self.view = view
        self.useCaseFactory = useCaseFactory ?? { (force: Bool) in
            return SubmissionDetailsUseCase(context: context, assignmentID: assignmentID, userID: userID)
        }
        self.submissionFrc = env.subscribe(Submission.self, .forUserOnAssignment(assignmentID, userID))
        self.assignmentFrc = env.subscribe(Assignment.self, .details(assignmentID))
        self.courseFrc = env.subscribe(Course.self, .details(context.id)) // TODO: support group contexts

        self.submissionFrc.delegate = self
        self.assignmentFrc.delegate = self
        self.courseFrc.delegate = self
    }

    func viewIsReady() {
        loadDataFromServer()
        loadData()
    }

    func loadDataFromServer(force: Bool = false) {
        let useCase = useCaseFactory(force)
        env.queue.addOperationWithErrorHandling(useCase, sendErrorsTo: view)
    }

    func loadData() {
        guard let assignment = loadAssignment() else { return }
        if let course = loadCourse() {
            view?.updateNavBar(subtitle: assignment.name, color: course.color)
        }

        let submissions = loadSubmissions()
        if selectedAttempt == 0 { selectedAttempt = submissions.last?.attempt ?? 0 }
        view?.update(assignment: assignment, submissions: submissions, selectedAttempt: selectedAttempt)
        embed(submissions.first(where: { $0.attempt == selectedAttempt }), assignment: assignment)
    }

    func loadSubmissions() -> [Submission] {
        submissionFrc.performFetch()
        return submissionFrc.fetchedObjects ?? []
    }

    func loadAssignment() -> Assignment? {
        assignmentFrc.performFetch()
        return assignmentFrc.fetchedObjects?.first
    }

    func loadCourse() -> Course? {
        courseFrc.performFetch()
        return courseFrc.fetchedObjects?.first
    }

    func select(attempt: Int) {
        selectedAttempt = attempt
        loadData()
    }

    func embed(_ submission: Submission?, assignment: Assignment) {
        guard contentSubmission != submission else { return }
        contentSubmission = submission
        var content: UIViewController?

        // external tools submission may be unsubmitted and the type nil but there could
        // still be a submission inside the tool
        if assignment.submissionTypes.contains(.external_tool) {
            content = ExternalToolSubmissionContentViewController.create(env: self.env, assignment: assignment)
            view?.embed(content)
            return
        }

        switch submission?.type {
        case .some(.online_quiz):
            if let quizID = assignment.quizID, let attempt = submission?.attempt,
                let url = URL(string: "/courses/\(assignment.courseID)/quizzes/\(quizID)/history?version=\(attempt)&headless=1", relativeTo: env.api.baseURL) {
                let controller = CoreWebViewController(env: env)
                controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.onlineQuizWebView"
                controller.webView.load(URLRequest(url: url))
                content = controller
            }
        case .some(.online_text_entry):
            let controller = CoreWebViewController(env: env)
            controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.onlineTextEntryWebView"
            controller.webView.loadHTMLString(submission?.body ?? "")
            content = controller
        case .some(.online_upload):
            // TODO: switch between multiple attachments in the same submission
            if let attachment = submission?.attachments?.first {
                content = DocViewerViewController.create(
                    filename: attachment.filename,
                    previewURL: attachment.previewURL,
                    fallbackURL: attachment.url,
                    navigationItem: view?.navigationItem,
                    env: env
                )
            }
        case .some(.discussion_topic):
            guard let previewUrl = submission?.previewUrl else { break }

            let controller = CoreWebViewController(env: env)
            controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.discussionWebView"
            controller.webView.load(URLRequest(url: previewUrl))
            content = controller
        case .some(.online_url):
            content = UrlSubmissionContentViewController.create(submission: submission)
        default:
            content = nil
        }
        view?.embed(content)
    }
}

extension SubmissionDetailsPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        loadData()
    }
}
