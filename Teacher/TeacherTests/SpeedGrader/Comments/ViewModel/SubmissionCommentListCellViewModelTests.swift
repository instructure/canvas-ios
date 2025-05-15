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

@testable import Core
import Combine
import SwiftUI
@testable import Teacher
import TestsFoundation
import XCTest

class SubmissionCommentListCellViewModelTests: TeacherTestCase {

    private enum TestConstants {
        static let commentId = "some commentId"
        static let attemptCommentId = "x-x-42" // specific format for `SubmissionComment.attempt`
        static let authorId = "some authorId"
        static let authorName = "some author name"
        static let commentText = "some comment text"
        static let courseId = "some courseId"
        static let currentUserId = "some currentUserId"
    }

    private var comment: SubmissionComment!
    private var assignment: Assignment!
    private var submission: Submission!

    override func setUp() {
        super.setUp()

        comment = SubmissionComment(context: databaseClient)
        comment.id = TestConstants.commentId
        comment.authorID = TestConstants.authorId
        comment.authorName = TestConstants.authorName
        comment.createdAt = Date.make(year: 2048, month: 4, day: 14)
        comment.comment = ""

        assignment = Assignment(context: databaseClient)
        assignment.courseID = TestConstants.courseId

        submission = Submission(context: databaseClient)
    }

    override func tearDown() {
        comment = nil
        assignment = nil
        submission = nil
        super.tearDown()
    }

    // MARK: - Properties

    func test_passedInProperties() {
        comment.authorPronouns = "some pronouns"
        let url = URL(string: "/some_author/avatar")!
        comment.authorAvatarURL = url

        let testee = makeViewModel()

        XCTAssertEqual(testee.id, TestConstants.commentId)
        XCTAssertEqual(testee.author.hasId, true)
        XCTAssertEqual(testee.author.name, TestConstants.authorName)
        XCTAssertEqual(testee.author.pronouns, "some pronouns")
        XCTAssertEqual(testee.author.avatarUrl, url)
        XCTAssertEqual(testee.date, comment.createdAtLocalizedString)
    }

    func test_authorIsCurrentUser() {
        comment.authorID = TestConstants.authorId

        var testee = makeViewModel(currentUserId: TestConstants.authorId)
        XCTAssertEqual(testee.author.isCurrentUser, true)

        testee = makeViewModel(currentUserId: TestConstants.currentUserId)
        XCTAssertEqual(testee.author.isCurrentUser, false)
    }

    func test_authorIsAnonymized() {
        assignment.anonymizeStudents = true
        var testee = makeViewModel()
        XCTAssertEqual(testee.author.isAnonymized, true)

        assignment.anonymizeStudents = false
        testee = makeViewModel()
        XCTAssertEqual(testee.author.isAnonymized, false)
    }

    func test_authorIsGroup() {
        submission.groupID = "some group id"
        var testee = makeViewModel()
        XCTAssertEqual(testee.author.isGroup, true)

        submission.groupID = nil
        testee = makeViewModel()
        XCTAssertEqual(testee.author.isGroup, false)
    }

    // MARK: - commentType

    func test_commentType_whenCommentIsText() {
        comment.id = TestConstants.commentId
        comment.mediaURL = nil

        comment.comment = TestConstants.commentText
        var testee = makeViewModel()
        XCTAssertEqual(testee.commentType.textComment, TestConstants.commentText)

        // empty text -> still a text comment
        comment.comment = ""
        testee = makeViewModel()
        XCTAssertEqual(testee.commentType.textComment, "")

        // files
        comment.attachments = [
            makeFile(id: "c"),
            makeFile(id: "a"),
            makeFile(id: "b")
        ]
        testee = makeViewModel()
        XCTAssertEqual(testee.commentType.textFiles?.map(\.id), ["a", "b", "c"])
    }

    func test_commentType_whenCommentIsMedia() {
        let mediaUrl = URL(string: "/some_media")
        comment.id = TestConstants.commentId
        comment.comment = TestConstants.commentText

        // audio with url -> audio
        comment.mediaType = .audio
        comment.mediaURL = mediaUrl
        var testee = makeViewModel()
        XCTAssertEqual(testee.commentType.audioUrl, mediaUrl)
        XCTAssertEqual(testee.commentType.textComment, nil)

        // audio without url -> fallback to text
        comment.mediaType = .audio
        comment.mediaURL = nil
        testee = makeViewModel()
        XCTAssertEqual(testee.commentType.audioUrl, nil)
        XCTAssertEqual(testee.commentType.textComment, TestConstants.commentText)

        // video with url -> video
        comment.mediaType = .video
        comment.mediaURL = mediaUrl
        testee = makeViewModel()
        XCTAssertEqual(testee.commentType.videoUrl, mediaUrl)
        XCTAssertEqual(testee.commentType.textComment, nil)

        // video without url -> fallback to text
        comment.mediaType = .video
        comment.mediaURL = nil
        testee = makeViewModel()
        XCTAssertEqual(testee.commentType.videoUrl, nil)
        XCTAssertEqual(testee.commentType.textComment, TestConstants.commentText)
    }

    func test_commentType_whenCommentIsOnlineUploadAttempt() {
        comment.id = TestConstants.attemptCommentId
        submission.type = .online_upload
        submission.attachments = [
            makeFile(id: "c"),
            makeFile(id: "a"),
            makeFile(id: "b")
        ]
        comment.attachments = [makeFile(id: "this should be ignored")]

        var testee = makeViewModel()
        XCTAssertEqual(testee.commentType.attemptWithAttachmentsNumber, 42)
        XCTAssertEqual(testee.commentType.attemptWithAttachmentsFiles?.map(\.id), ["a", "b", "c"])

        // no attachments -> still an attemptWithAttachments
        submission.type = .online_upload
        submission.attachments = nil
        testee = makeViewModel()
        XCTAssertEqual(testee.commentType.attemptWithAttachmentsNumber, 42)
        XCTAssertEqual(testee.commentType.attemptWithAttachmentsFiles?.map(\.id), [])
    }

    func test_commentType_whenCommentIsAttemptOtherThanOnlineUpload() {
        comment.id = TestConstants.attemptCommentId
        submission.type = .media_recording
        submission.attachments = [makeFile(id: "this should be ignored")]

        let testee = makeViewModel()
        XCTAssertEqual(testee.commentType.attemptNumber, 42)
        XCTAssertEqual(testee.commentType.attemptSubmission?.id, submission.id)
    }

    // MARK: - contextColor

    func test_contextColor() {
        let publisher = PassthroughSubject<Color, Never>()

        let testee = makeViewModel(contextColor: publisher.eraseToAnyPublisher())
        XCTAssertEqual(testee.contextColor.hexString, Brand.shared.primary.hexString)

        publisher.send(.green)
        XCTAssertEqual(testee.contextColor.hexString, Color.green.hexString)
    }

    // MARK: - Actions

    func test_didTapAvatarButton() {
        let sourceVC = UIViewController()
        let testee = makeViewModel()

        testee.didTapAvatarButton.send(.init(sourceVC))

        let path = "/courses/\(TestConstants.courseId)/users/\(TestConstants.authorId)"
        XCTAssertEqual(router.calls.last?.0, URLComponents(string: path))
        XCTAssertEqual(router.calls.last?.1, sourceVC)
        XCTAssertEqual(router.calls.last?.2, .modal(embedInNav: true, addDoneButton: true))
    }

    func test_didTapFileButton() {
        let sourceVC = UIViewController()
        let testee = makeViewModel()

        testee.didTapFileButton.send(("some_fileId", .init(sourceVC)))

        let path = "/files/some_fileId"
        XCTAssertEqual(router.calls.last?.0, URLComponents(string: path))
        XCTAssertEqual(router.calls.last?.1, sourceVC)
        XCTAssertEqual(router.calls.last?.2, .modal(embedInNav: true, addDoneButton: true))
    }

    // MARK: - Accessibility

    func test_accessibilityLabelForHeader() {
        let testee = makeViewModel()

        XCTAssertEqual(testee.accessibilityLabelForHeader, comment.accessibilityLabelForHeader)
    }

    func test_accessibilityLabelForAttempt() {
        submission.attempt = 7
        submission.type = .media_recording

        let testee = makeViewModel()

        XCTAssertEqual(testee.accessibilityLabelForAttempt, comment.accessibilityLabelForAttempt(submission: submission))
    }

    func test_accessibilityLabelForCommentAttachment() {
        let file = makeFile()
        file.displayName = "some filename"
        file.size = 1984

        let testee = makeViewModel()
        XCTAssertEqual(
            testee.accessibilityLabelForCommentAttachment(file),
            comment.accessibilityLabelForCommentAttachment(file)
        )
    }

    func test_accessibilityLabelForAttemptAttachment() {
        submission.attempt = 7
        submission.type = .media_recording
        let file = makeFile()
        file.displayName = "some filename"
        file.size = 1984

        let testee = makeViewModel()
        XCTAssertEqual(
            testee.accessibilityLabelForAttemptAttachment(file),
            comment.accessibilityLabelForAttemptAttachment(file, submission: submission)
        )
    }

    // MARK: - Private helpers

    private func makeViewModel(
        currentUserId: String? = TestConstants.currentUserId,
        contextColor: AnyPublisher<Color, Never> = Publishers.typedEmpty()
    ) -> SubmissionCommentListCellViewModel {
        SubmissionCommentListCellViewModel(
            comment: comment,
            assignment: assignment,
            submission: submission,
            currentUserId: currentUserId,
            contextColor: contextColor,
            router: router
        )
    }

    private func makeFile(id: String = "") -> File {
        File.save(.make(id: .init(id)), in: databaseClient)
    }
}

private extension SubmissionCommentListCellViewModel.CommentType {
    var textComment: String? {
        guard case let .text(comment, _) = self else { return nil }
        return comment
    }

    var textFiles: [File]? {
        guard case let .text(_, files) = self else { return nil }
        return files
    }

    var audioUrl: URL? {
        guard case let .audio(url) = self else { return nil }
        return url
    }

    var videoUrl: URL? {
        guard case let .video(url) = self else { return nil }
        return url
    }

    var attemptNumber: Int? {
        guard case let .attempt(attemptNumber, _) = self else { return nil }
        return attemptNumber
    }

    var attemptSubmission: Submission? {
        guard case let .attempt(_, submission) = self else { return nil }
        return submission
    }

    var attemptWithAttachmentsNumber: Int? {
        guard case let .attemptWithAttachments(attemptNumber, _) = self else { return nil }
        return attemptNumber
    }

    var attemptWithAttachmentsFiles: [File]? {
        guard case let .attemptWithAttachments(_, files) = self else { return nil }
        return files
    }
}
