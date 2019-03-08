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

public protocol SubmissionDetailsViewProtocol: class {
    func reload()
    func reloadNavBar()
    func embed()
    var navigationItem: UINavigationItem { get }
}

class SubmissionDetailsPresenter {
    let context: Context
    let assignmentID: String
    let userID: String
    let env: AppEnvironment
    weak var view: SubmissionDetailsViewProtocol?

    lazy var submissions: Store<GetSubmission> = {
        let useCase = GetSubmission(context: context, assignmentID: assignmentID, userID: userID)
        return env.subscribe(useCase) { [weak self] in
            self?.view?.embed()
            self?.view?.reload()
        }
    }()

    lazy var assignment: Store<GetAssignment> = {
        let useCase = GetAssignment(courseID: context.id, assignmentID: assignmentID)
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reload()
            self?.view?.reloadNavBar()
        }
    }()

    lazy var course: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: context.id)
        return env.subscribe(useCase) { [weak self] in
            self?.view?.reloadNavBar()
        }
    }()

    init(env: AppEnvironment = .shared, view: SubmissionDetailsViewProtocol, context: Context, assignmentID: String, userID: String) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        submissions.refresh(force: true)
        assignment.refresh(force: true)
        course.refresh(force: false)
    }

    func submissionFor(attempt: Int) -> Submission? {
        guard submissions.count > 0 else {
            return nil
        }
        if attempt == 0 {
            return submissions.first
        }
        return submissions.filter({ $0.attempt == attempt }).first
    }

    func viewControllerFor(attempt: Int) -> UIViewController? {
        guard let submission = self.submissionFor(attempt: attempt), let assignment = assignment.first else {
            return nil
        }

        // external tools submission may be unsubmitted and the type nil but there could
        // still be a submission inside the tool
        if assignment.submissionTypes.contains(.external_tool) {
            return ExternalToolSubmissionContentViewController.create(env: self.env, assignment: assignment)
        }

        switch submission.type {
        case .some(.online_quiz):
            if let quizID = assignment.quizID,
                let url = URL(string: "/courses/\(assignment.courseID)/quizzes/\(quizID)/history?version=\(attempt)&headless=1", relativeTo: env.api.baseURL) {
                let controller = CoreWebViewController(env: env)
                controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.onlineQuizWebView"
                controller.webView.load(URLRequest(url: url))
                return controller
            }
        case .some(.online_text_entry):
            let controller = CoreWebViewController(env: env)
            controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.onlineTextEntryWebView"
            controller.webView.loadHTMLString(submission.body ?? "")
            return controller
        case .some(.online_upload):
            // TODO: switch between multiple attachments in the same submission
            if let attachment = submission.attachments?.first {
                return DocViewerViewController.create(
                    filename: attachment.filename,
                    previewURL: attachment.previewURL,
                    fallbackURL: attachment.url,
                    navigationItem: view?.navigationItem,
                    env: env
                )
            }
        case .some(.discussion_topic):
            guard let previewUrl = submission.previewUrl else { break }

            let controller = CoreWebViewController(env: env)
            controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.discussionWebView"
            controller.webView.load(URLRequest(url: previewUrl))
            return controller
        case .some(.online_url):
            return UrlSubmissionContentViewController.create(submission: submission)
        default:
            return nil
        }
        return nil
    }

}
