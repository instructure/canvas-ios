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
    private var attempt: Int?
    lazy var assignment = env.subscribe(GetAssignment(courseID: context.id, assignmentID: assignmentID)) {}

    init(env: AppEnvironment = .shared, view: SubmissionCommentsViewProtocol, context: Context, assignmentID: String, userID: String, submissionID: String) {
        self.assignmentID = assignmentID
        self.context = context
        self.env = env
        self.submissionID = submissionID
        self.view = view
        self.userID = userID
    }

    func viewIsReady() {
        assignment.refresh()
        commentsStore.refresh()
        view?.reload()
    }

    func update() {
        comments = commentsStore.all.filter {
            $0.attemptFromAPI == nil || $0.attemptFromAPI?.intValue == attempt
        }
        view?.reload()
    }

    func updateComments(for attempt: Int?) {
        self.attempt = attempt
        update()
    }

    func addComment(text: String) {
        CreateTextComment(
            courseID: context.id,
            assignmentID: assignmentID,
            userID: userID,
            isGroup: assignment.first?.gradedIndividually == false,
            text: text
        ).fetch { [weak self] comment, error in
            if error != nil || comment == nil {
                self?.view?.showError(error ?? NSError.instructureError(NSLocalizedString("Could not save the comment", bundle: .student, comment: "")))
            }
        }
    }

    func addMediaComment(type: MediaCommentType, url: URL) {
        UploadMediaComment(
            courseID: context.id,
            assignmentID: assignmentID,
            userID: userID,
            isGroup: assignment.first?.gradedIndividually == false,
            type: type,
            url: url
        ).fetch { [weak self] comment, error in
            if error != nil || comment == nil {
                self?.view?.showError(error ?? NSError.instructureError(NSLocalizedString("Could not save the comment", bundle: .student, comment: "")))
            }
        }
    }

    func addFileComment(batchID: String) {
        UploadFileComment(
            courseID: context.id,
            assignmentID: assignmentID,
            userID: userID,
            isGroup: assignment.first?.gradedIndividually == false,
            batchID: batchID
        ).fetch { [weak self] comment, error in
            if error != nil || comment == nil {
                self?.view?.showError(error ?? NSError.instructureError(NSLocalizedString("Could not save the comment", bundle: .student, comment: "")))
            }
        }
    }

    func showAttachment(_ attachment: File, from viewController: UIViewController) {
        guard let url = attachment.url else { return }
        env.router.route(to: url, from: viewController, options: .modal(embedInNav: true, addDoneButton: true))
    }
}
