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

import Foundation
import Core
import CoreData

protocol SubmissionCommentAttemptDelegate: AnyObject {
    func updateComments(for attempt: Int?)
}

protocol SubmissionCommentsViewProtocol: AnyObject {
    func reload()
    func showError(_ error: Error)
}

class SubmissionCommentsPresenter: SubmissionCommentAttemptDelegate {
    let assignmentID: String
    let context: Context
    let env: AppEnvironment
    let submissionID: String
    weak var view: SubmissionCommentsViewProtocol?
    let userID: String

    var comments = [SubmissionComment]()
    lazy var commentsStore = env.subscribe(GetSubmissionComments(
        context: context,
        assignmentID: assignmentID,
        userID: userID
    )) { [weak self] in
        self?.update()
    }
    lazy var featuresStore = env.subscribe(GetEnabledFeatureFlags(context: .course(context.id))) { [weak self] in
         self?.update()
    }
    private var attempt: Int?
    lazy var assignment = env.subscribe(GetAssignment(courseID: context.id, assignmentID: assignmentID)) {}

    init(env: AppEnvironment, view: SubmissionCommentsViewProtocol, context: Context, assignmentID: String, userID: String, submissionID: String) {
        self.assignmentID = assignmentID
        self.context = context
        self.env = env
        self.submissionID = submissionID
        self.view = view
        self.userID = userID
    }

    func viewIsReady() {
        assignment.refresh()
        featuresStore.refresh()
        commentsStore.refresh()
        view?.reload()
    }

    func update() {
        if featuresStore.isFeatureFlagEnabled(.assignmentEnhancements) {
            comments = commentsStore.all.filter {
                $0.attemptFromAPI == nil || $0.attemptFromAPI?.intValue == attempt
            }
        } else {
            comments = commentsStore.all
        }
        view?.reload()
    }

    func updateComments(for attempt: Int?) {
        if featuresStore.isFeatureFlagEnabled(.assignmentEnhancements) {
            self.attempt = attempt
        }
        update()
    }

    func addComment(text: String) {
        CreateTextComment(
            env: env,
            courseID: context.id,
            assignmentID: assignmentID,
            userID: userID,
            isGroup: assignment.first?.gradedIndividually == false,
            text: text,
            attempt: attempt
        ).fetch { [weak self] comment, error in
            if error != nil || comment == nil {
                self?.view?.showError(error ?? NSError.instructureError(String(localized: "Could not save the comment", bundle: .student)))
            } else {
                UIAccessibility.announce(String(localized: "Comment sent successfully", bundle: .student))
            }
        }
    }

    func addMediaComment(type: MediaCommentType, url: URL) {
        UploadMediaComment(
            env: env,
            courseID: context.id,
            assignmentID: assignmentID,
            userID: userID,
            isGroup: assignment.first?.gradedIndividually == false,
            type: type,
            url: url,
            attempt: attempt
        ).fetch { [weak self] comment, error in
            if error != nil || comment == nil {
                self?.view?.showError(error ?? NSError.instructureError(String(localized: "Could not save the comment", bundle: .student)))
            }
        }
    }

    func addFileComment(batchID: String) {
        UploadFileComment(
            env: env,
            courseID: context.id,
            assignmentID: assignmentID,
            userID: userID,
            isGroup: assignment.first?.gradedIndividually == false,
            batchID: batchID,
            attempt: attempt
        ).fetch { [weak self] comment, error in
            if error != nil || comment == nil {
                self?.view?.showError(error ?? NSError.instructureError(String(localized: "Could not save the comment", bundle: .student)))
            }
        }
    }

    func showAttachment(_ attachment: File, from viewController: UIViewController) {
        guard let url = attachment.url else { return }
        env.router.route(to: url, from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
    }
}
