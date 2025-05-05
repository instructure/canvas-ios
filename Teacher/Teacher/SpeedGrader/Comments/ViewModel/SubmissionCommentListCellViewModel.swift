//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine
import Core
import SwiftUI

final class SubmissionCommentListCellViewModel: ObservableObject {

    struct Author {
        var id: String?
        var name: String
        var pronouns: String?
        var avatarUrl: URL?
        var isCurrentUser: Bool
        var isAnonymized: Bool
        var isGroup: Bool

        var hasId: Bool {
            id != nil
        }
    }

    enum CommentType {
        case text(String, [File])
        case audio(URL)
        case video(URL)
        case attempt(Int, Submission)
        case attemptWithAttachments(Int, [File])
    }

    // MARK: - Output

    let id: String
    let author: Author
    let date: String
    let commentType: CommentType

    // MARK: - Input

    let didTapAvatarButton = PassthroughSubject<WeakViewController, Never>()
    let didTapFileButton = PassthroughSubject<(String?, WeakViewController), Never>()

    // MARK: - Private properties

    private let comment: SubmissionComment
    private let submission: Submission
    private let courseId: String
    private let router: Router

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        comment: SubmissionComment,
        assignment: Assignment,
        submission: Submission,
        currentUserId: String?,
        router: Router
    ) {
        self.comment = comment
        self.submission = submission
        self.courseId = assignment.courseID
        self.router = router

        self.id = comment.id

        self.author = Author(
            id: comment.authorID,
            name: comment.authorName,
            pronouns: comment.authorPronouns,
            avatarUrl: comment.authorAvatarURL,
            isCurrentUser: comment.authorID == currentUserId,
            isAnonymized: assignment.anonymizeStudents,
            isGroup: submission.groupID != nil
        )

        self.date = comment.createdAtLocalizedString

        let commentType: CommentType
        if let attempt = comment.attempt {
            if submission.type == .online_upload {
                let files = submission.attachments?.sorted(by: File.idCompare) ?? []
                commentType = .attemptWithAttachments(attempt, files)
            } else {
                commentType = .attempt(attempt, submission)
            }
        } else if comment.mediaType == .audio, let url = comment.mediaLocalOrRemoteURL {
            commentType = .audio(url)
        } else if comment.mediaType == .video, let url = comment.mediaLocalOrRemoteURL {
            commentType = .video(url)
        } else {
            let files = comment.attachments?.sorted(by: File.idCompare) ?? []
            commentType = .text(comment.comment, files)
        }
        self.commentType = commentType

        showUserDetails(on: didTapAvatarButton)
        showFile(on: didTapFileButton)
    }

    // MARK: - Subscriptions

    private func showUserDetails(on subject: PassthroughSubject<WeakViewController, Never>) {
        subject
            .sink { [weak self] controller in
                guard let self, let authorId = author.id else { return }

                router.route(
                    to: "/courses/\(courseId)/users/\(authorId)",
                    userInfo: ["navigatorOptions": ["modal": true]], // fix nav style
                    from: controller,
                    options: .modal(embedInNav: true, addDoneButton: true)
                )
            }
            .store(in: &subscriptions)
    }

    private func showFile(on subject: PassthroughSubject<(String?, WeakViewController), Never>) {
        subject
            .sink { [weak self] fileId, controller in
                guard let self, let fileId else { return }

                router.route(
                    to: "/files/\(fileId)",
                    from: controller,
                    options: .modal(embedInNav: true, addDoneButton: true)
                )
            }
            .store(in: &subscriptions)
    }

    // MARK: - Accessibility

    lazy var accessibilityLabelForHeader: String = comment.accessibilityLabelForHeader
    lazy var accessibilityLabelForAttempt: String = comment.accessibilityLabelForAttempt(submission: submission)

    func accessibilityLabelForCommentAttachment(_ file: File) -> String {
        comment.accessibilityLabelForCommentAttachment(file)
    }

    func accessibilityLabelForAttemptAttachment(_ file: File) -> String {
        comment.accessibilityLabelForAttemptAttachment(file, submission: submission)
    }
}
