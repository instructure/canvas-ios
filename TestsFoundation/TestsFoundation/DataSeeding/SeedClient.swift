//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core

public let AdminToken = Secret.dataSeedingAdminToken.string!

public struct SeedClient {
    enum SeedError: Error {
        case invalidResponse
    }

    public let baseURL: URL
    public let queue = OperationQueue()
    public let host: TestHost

    public init(host: TestHost) {
        self.baseURL = URL(string: "https://mobileqa.test.instructure.com")!
        self.host = host
    }

    @discardableResult
    public func makeRequest<Request: APIRequestable>(_ request: Request, with token: String, api: API? = nil) -> Request.Response {
        let api = api ?? URLSessionAPI(accessToken: token, baseURL: baseURL)
        let operation = APIOperation(api: api, request: request)
        queue.addOperations([operation], waitUntilFinished: true)
        guard let response = operation.response else {
            let error = operation.errors.first
            let message = error?.localizedDescription ?? "error not found"
            if let error = error {
                print(error)
            }
            fatalError(message)
        }
        return response
    }

    public func createCourse(name: String = "A Course", default_view: CourseDefaultView = .feed) -> APICourse {
        let request = PostCourseRequest(accountID: "self", body: .init(course: .init(name: name, default_view: default_view)))
        return makeRequest(request, with: AdminToken)
    }

    public func createUser() -> APIUser {
        let name = "User"
        let email = Randomizer.randomEmail()
        let password = "password"
        let request = CreateUserRequest(accountID: "self", body: .init(user: .init(name: name), pseudonym: .init(unique_id: email, password: password)))
        return makeRequest(request, with: AdminToken)
    }

    public func createTeacher(in course: APICourse) -> APIUser {
        let user = createUser()
        enroll(user: user, inCourse: course, as: .teacher)
        return user
    }

    public func createStudent(in course: APICourse) -> APIUser {
        let user = createUser()
        enroll(user: user, inCourse: course, as: .student)
        return user
    }

    @discardableResult
    public func enroll(user: APIUser, inCourse course: APICourse, as role: EnrollmentRole) -> APIEnrollment {
        let request = PostEnrollmentRequest(courseID: course.id, body: .init(enrollment: .init(user_id: user.id, type: role, enrollment_state: .active)))
        return makeRequest(request, with: AdminToken)
    }

    public func createAssignment(
        for course: APICourse,
        name: String = "Assignment",
        description: String? = "A description",
        pointsPossible: Double = 10,
        dueAt: Date? = nil,
        submissionTypes: [SubmissionType] = [.online_text_entry],
        allowedExtensions: [String] = [],
        published: Bool = true,
        gradingType: GradingType = .points,
        lockAt: Date? = nil,
        unlockAt: Date? = nil
    ) -> APIAssignment {
        let assignment = APIAssignmentParameters(
            name: name,
            description: description,
            points_possible: pointsPossible,
            due_at: dueAt,
            submission_types: submissionTypes,
            allowed_extensions: allowedExtensions,
            published: published,
            grading_type: gradingType,
            lock_at: lockAt,
            unlock_at: unlockAt
        )
        let request = PostAssignmentRequest(courseID: course.id, body: .init(assignment: assignment))
        return makeRequest(request, with: AdminToken)
    }

    public func createGradedDiscussionTopic(
        for course: APICourse,
        title: String = "Discussion topic",
        message: String = "A discussion message",
        pointsPossible: Double = 10,
        dueAt: Date? = nil,
        published: Bool = true,
        gradingType: GradingType = .points,
        lockAt: Date? = nil,
        unlockAt: Date? = nil
        ) -> APIDiscussionTopic {
        let assignment = APIAssignmentParameters(
            name: title,
            description: message,
            points_possible: pointsPossible,
            due_at: dueAt,
            submission_types: [SubmissionType.discussion_topic],
            allowed_extensions: [],
            published: published,
            grading_type: gradingType,
            lock_at: lockAt,
            unlock_at: unlockAt
        )
        let body = PostDiscussionTopicRequest.Body(
            title: title,
            message: message,
            published: published,
            assignment: assignment
        )
        let context = ContextModel(.course, id: course.id)
        let request = PostDiscussionTopicRequest(context: context, body: body)
        return makeRequest(request, with: AdminToken)
    }

    public func getToken(email: String, password: String, callback: @escaping (String) -> Void) -> NSObjectProtocol {
        // getToken must be done by the TestHost because it uses a web view on the main thread
        // We can remove it from the TestHost once we have better oauth2 support
        return host.getToken(host: baseURL.host!, id: email, password: password, callback: callback)
    }

    public func updateCustomColor(user: AuthUser, context: Context, hexcode: String = "fffeee") {
        let request = UpdateCustomColorRequest(userID: user.id, context: context, body: .init(hexcode: hexcode))
        makeRequest(request, with: user.token)
    }

    @discardableResult
    public func submit(
        assignment: APIAssignment,
        context: Context,
        as user: AuthUser,
        submissionType: SubmissionType = .online_text_entry,
        body: String? = "a submission",
        url: URL? = nil,
        fileIDs: [String]? = nil,
        mediaCommentID: String? = nil,
        mediaCommentType: MediaCommentType? = nil,
        comment: String? = nil
    ) -> APISubmission {
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: comment,
            submission_type: submissionType,
            body: body,
            url: url,
            file_ids: fileIDs,
            media_comment_id: mediaCommentID,
            media_comment_type: mediaCommentType
        )
        let request = CreateSubmissionRequest(
            context: context,
            assignmentID: assignment.id.value,
            body: .init(submission: submission)
        )
        return makeRequest(request, with: user.token)
    }

    @discardableResult
    public func resubmit(
        assignment: APIAssignment,
        context: Context,
        as user: AuthUser,
        submissionType: SubmissionType = .online_text_entry,
        body: String? = "a re-submission",
        url: URL? = nil,
        fileIDs: [String]? = nil,
        mediaCommentID: String? = nil,
        mediaCommentType: MediaCommentType? = nil,
        comment: String? = nil
    ) -> APISubmission {
        var ready = false
        // Submitting twice in quick succession seems to cause canvas to
        // lose one of the submissions. When resubmitting we want to ensure
        // that another submission exists with an attempt before trying to submit again
        for _ in 1...3 {
            let getSubmissionRequest = GetSubmissionRequest(context: context, assignmentID: assignment.id.value, userID: user.id)
            let submission = makeRequest(getSubmissionRequest, with: user.token)
            if submission.attempt != nil {
                ready = true
                break
            }
        }
        if ready {
            return submit(assignment: assignment, context: context, as: user, submissionType: submissionType, body: body, url: url, fileIDs: fileIDs, mediaCommentID: mediaCommentID, mediaCommentType: mediaCommentType, comment: comment)
        } else {
            fatalError("Can't resubmit to an assignment that hasn't been submitted to.")
        }
    }

    @discardableResult
    public func gradeSubmission(
        course: APICourse,
        assignment: APIAssignment,
        userID: String,
        as teacher: AuthUser,
        grade: String
    ) -> APISubmission {
        let request = PutSubmissionGradeRequest(courseID: course.id, assignmentID: assignment.id.value, userID: userID, body: .init(
            comment: nil,
            submission: .init(posted_grade: grade)
        ))
        return makeRequest(request, with: teacher.token)
    }

    @discardableResult
    public func commentOnSumbission(
        course: APICourse,
        assignment: APIAssignment,
        userID: String,
        as teacher: AuthUser,
        comment: String
    ) -> APISubmissionComment {
        let request = PutSubmissionGradeRequest(courseID: course.id, assignmentID: assignment.id.value, userID: userID, body: .init(
            comment: .init(text_comment: comment),
            submission: nil
        ))
        return makeRequest(request, with: teacher.token).submission_comments!.last!
    }

    @discardableResult
    public func createLatePolicy(
        for course: APICourse,
        as user: AuthUser,
        lateSubmissionDeductionEnabled: Bool? = true,
        lateSubmissionDeduction: Double? = 10,
        lateSubmissionInterval: LatePolicyInterval = .day
    ) -> APILatePolicy {
        let body = PostLatePolicyRequest.Body(late_policy: .init(late_submission_deduction_enabled: lateSubmissionDeductionEnabled, late_submission_deduction: lateSubmissionDeduction, late_submission_interval: lateSubmissionInterval))
        let request = PostLatePolicyRequest(courseID: course.id, body: body)
        return makeRequest(request, with: user.token).late_policy
    }

    @discardableResult
    public func uploadFile(
        url: URL,
        named name: String? = nil,
        for assignment: APIAssignment,
        as user: AuthUser
    ) -> APIFile {
        let target = makeRequest(PostFileUploadTargetRequest(
           target: .submission(courseID: assignment.course_id.value, assignmentID: assignment.id.value),
           body: .init(name: name ?? url.lastPathComponent, on_duplicate: .rename, parent_folder_id: nil)
        ), with: user.token)
        return makeRequest(PostFileUploadRequest(fileURL: url, target: target), with: user.token)
    }

    @discardableResult
    public func uploadFile(
        url: URL,
        named name: String? = nil,
        as user: AuthUser
    ) -> APIFile {
        let target = makeRequest(PostFileUploadTargetRequest(
            target: .myFiles,
            body: .init(name: name ?? url.lastPathComponent, on_duplicate: .rename, parent_folder_id: nil)
        ), with: user.token)
        return makeRequest(PostFileUploadRequest(fileURL: url, target: target), with: user.token)
    }

    public func createDocViewerSession(for file: APIFile, as user: AuthUser) -> DocViewerSession {
        var session: DocViewerSession?
        let operation = AsyncBlockOperation { done in
            session = DocViewerSession {
                done(nil)
            }
            session?.load(url: URL(string: file.preview_url!.absoluteString, relativeTo: self.baseURL)!, accessToken: user.token)
        }
        queue.addOperations([operation], waitUntilFinished: true)
        return session!
    }

    @discardableResult
    public func pollForDocViewerMetadata(session: DocViewerSession) -> APIDocViewerMetadata {
        var triesLeft = 30
        while triesLeft > 0 {
            triesLeft -= 1
            if let metadata = session.metadata {
                return metadata
            }
            let operation = AsyncBlockOperation { done in
                session.callback = { done(nil) }
                session.error = nil
                session.loadMetadata(sessionURL: session.sessionURL)
            }
            queue.addOperations([operation], waitUntilFinished: true)
            if let metadata = session.metadata {
                return metadata
            }
            if let error = session.error { print(error.localizedDescription) }
            sleep(2) // 2 * 30 = up to 1 minute of polling
        }
        fatalError("Could not get the metadata for DocViewer session.")
    }

    @discardableResult
    public func createAnnotation(_ annotation: APIDocViewerAnnotation, on session: DocViewerSession) -> APIDocViewerAnnotation {
        return makeRequest(PutDocViewerAnnotationRequest(body: annotation, sessionID: session.sessionID!), with: "", api: session.api)
    }

    @discardableResult
    public func createQuiz(
        in course: APICourse,
        as user: AuthUser,
        title: String = "Test Quiz",
        description: String? = "A description",
        published: Bool? = true,
        questions: [(question_name: String?, question_text: String?, question_type: QuizQuestionType, points_possible: Int?)] = []
    ) -> (APIQuiz, [APIQuizQuestion]) {
        let postQuiz = PostQuizRequest(courseID: course.id, body: .init(quiz: .init(
            title: title,
            description: description,
            published: published
        )))
        let quiz = makeRequest(postQuiz, with: user.token)
        var quizQuestions = [APIQuizQuestion]()
        for question in questions {
            let postQuestion = PostQuizQuestionRequest(courseID: course.id, quizID: quiz.id, body: .init(question: .init(
                question_name: question.question_name,
                question_text: question.question_text,
                question_type: question.question_type,
                points_possible: question.points_possible
            )))
            quizQuestions.append(makeRequest(postQuestion, with: user.token))
        }
        return (quiz, quizQuestions)
    }

    @discardableResult
    public func takeQuiz(
        _ quiz: APIQuiz,
        in course: APICourse,
        as user: AuthUser,
        answers: [String: APIQuizAnswerValue] = [:],
        complete: Bool = true
    ) -> APIQuizSubmission {
        let postSubmission = PostQuizSubmissionRequest(courseID: course.id, quizID: quiz.id, body: .init(
            access_code: nil,
            preview: nil
        ))
        let submission = makeRequest(postSubmission, with: user.token).quiz_submissions[0]
        if !answers.isEmpty {
            let postAnswers = PostQuizSubmissionQuestionRequest(quizSubmissionID: submission.id, body: .init(
                attempt: submission.attempt,
                validation_token: submission.validation_token,
                access_code: nil,
                quiz_questions: answers.map { id, answer in
                    return PostQuizSubmissionQuestionRequest.Body.Question(id: id, answer: answer)
                }
            ))
            makeRequest(postAnswers, with: user.token)
        }
        if complete {
            let postComplete = PostQuizSubmissionCompleteRequest(
                courseID: course.id,
                quizID: quiz.id,
                quizSubmissionID: submission.id,
                body: .init(attempt: submission.attempt, validation_token: submission.validation_token, access_code: nil)
            )
            makeRequest(postComplete, with: user.token)
        }
        return submission
    }

    public func healthCheck() -> APIHealthCheck {
        let request = GetHealthCheckRequest()
        return makeRequest(request, with: AdminToken)
    }

    @discardableResult
    public func createDiscussionEntry(_ discussion: APIDiscussionTopic, context: Context, message: String, as user: AuthUser) -> APIDiscussionEntry {
        let request = PostDiscussionEntryRequest(context: context, topicID: discussion.id.value, body: PostDiscussionEntryRequest.Body(message: message))
        return makeRequest(request, with: user.token)
    }
}
