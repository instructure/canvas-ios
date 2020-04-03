//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core

enum MiniCanvasEndpoints {
    private enum Pattern {
        static let courseID = ":courseID"
        static let assignmentID = ":assignmentID"
        static let quizID = ":quizID"
        static let userID = ":userID"
        static let courseContext = ContextModel(ContextType.course, id: courseID)
    }

    private static func lookupCourse<T>(forRequest request: MiniCanvasServer.APIRequest<T>) throws -> MiniCourse {
        guard let course = request.state.course(byId: request[Pattern.courseID]!) else {
            throw ServerError.notFound
        }
        return course
    }

    private static func lookupAssignment<T>(forRequest request: MiniCanvasServer.APIRequest<T>) throws -> MiniAssignment {
        guard let assignment = try lookupCourse(forRequest: request).assignment(byId: request[Pattern.assignmentID]!) else {
            throw ServerError.notFound
        }
        return assignment
    }

    private static func lookupSubmission<T>(forRequest request: MiniCanvasServer.APIRequest<T>) throws -> MiniSubmission {
        guard let submission = try lookupAssignment(forRequest: request).submission(byUserId: request[Pattern.userID]!) else {
            throw ServerError.notFound
        }
        return submission
    }

    private static func lookupQuiz<T>(forRequest request: MiniCanvasServer.APIRequest<T>) throws -> MiniQuiz {
        guard let quiz = try lookupCourse(forRequest: request).quiz(byId: request[Pattern.quizID]!) else {
            throw ServerError.notFound
        }
        return quiz
    }

    private static func lookupUser<T>(forRequest request: MiniCanvasServer.APIRequest<T>) throws -> APIUser {
        var id = request[Pattern.userID]!
        if id == "self" {
            id = request.state.selfId
        }
        guard let user = request.state.user(byId: id) else {
            throw ServerError.notFound
        }
        return user
    }

    public static let endpoints: [MiniCanvasServer.Endpoint] = [
        // MARK: Account Notifications
        // https://canvas.instructure.com/doc/api/account_notifications.html
        .apiRequest(GetAccountNotificationsRequest()) { request in request.state.accountNotifications },
        .apiRequest(DeleteAccountNotificationRequest(id: ":id")) { request in
            let id = ID(request[":id"]!)
            request.state.accountNotifications.removeAll(where: { $0.id == id })
            return APINoContent()
        },

        // MARK: Assignment Groups
        // https://canvas.instructure.com/doc/api/assignment_groups.html
        .apiRequest(GetAssignmentGroupsRequest(courseID: Pattern.courseID)) { request in
            try lookupCourse(forRequest: request).assignmentGroups
        },

        // MARK: Assignments
        // https://canvas.instructure.com/doc/api/assignments.html
        .apiRequest(GetAssignmentsRequest(courseID: Pattern.courseID)) { request in
            try lookupCourse(forRequest: request).assignments.map { $0.api }
        },
        .apiRequest(GetAssignmentRequest(courseID: Pattern.courseID, assignmentID: Pattern.assignmentID, include: [])) { request in
            try lookupAssignment(forRequest: request).api
        },
        .graphQL(AssignmentListRequestable.self) { request in
            let vars = request.body.variables
            let assignments: [APIAssignmentListAssignment] = try lookupCourse(forRequest: request).assignments.map { assignment in
                APIAssignmentListAssignment.make(
                    id: assignment.api.id,
                    name: assignment.api.name,
                    dueAt: assignment.api.due_at,
                    lockAt: assignment.api.lock_at,
                    unlockAt: assignment.api.unlock_at,
                    htmlUrl: "\(assignment.api.html_url)",
                    submissionTypes: assignment.api.submission_types,
                    quizID: assignment.api.quiz_id
                )
            }
            return APIAssignmentListResponse.make(groups: [.make(assignments: assignments)])
        },

        // MARK: Brand
        // https://canvas.instructure.com/doc/api/brand_configs.html
        .apiRequest(GetBrandVariablesRequest()) { request in request.state.brandVariables },

        // MARK: Conversations
        // https://canvas.instructure.com/doc/api/conversations.html
        .apiRequest(GetConversationsUnreadCountRequest()) { request in
            .init(unread_count: request.state.unreadCount)
        },

        // MARK: Courses
        // https://canvas.instructure.com/doc/api/conversations.html
        .apiRequest(GetCoursesRequest()) { request in request.state.courses.map { $0.api } },
        .apiRequest(GetCourseRequest(courseID: Pattern.courseID)) { request in
            try lookupCourse(forRequest: request).api
        },

        // MARK: Enrollments
        // https://canvas.instructure.com/doc/api/enrollments.html
        .apiRequest(GetEnrollmentsRequest(context: ContextModel.currentUser)) { request in
            request.state.userEnrollments()
        },
        .apiRequest(GetEnrollmentsRequest(context: Pattern.courseContext)) { request in
            request.state.enrollments.filter { $0.course_id == request[Pattern.courseID]! }
        },

        // MARK: Feature Flags
        // https://canvas.instructure.com/doc/api/feature_flags.html
        .apiRequest(GetEnabledFeatureFlagsRequest(context: Pattern.courseContext)) { request in
            try lookupCourse(forRequest: request).featureFlags
        },

        // MARK: Grading Periods
        // https://canvas.instructure.com/doc/api/grading_periods.html
        .apiRequest(GetGradingPeriodsRequest(courseID: Pattern.courseID)) { request in
            try lookupCourse(forRequest: request).gradingPeriods
        },

        // MARK: Groups
        // https://canvas.instructure.com/doc/api/groups.html
        .apiRequest(GetGroupsRequest(context: ContextModel.currentUser)) { _ in [] },
        .apiRequest(GetGroupsRequest(context: Pattern.courseContext)) { _ in [] },

        // MARK: OAuth
        // https://canvas.instructure.com/doc/api/file.oauth_endpoints.html
        .rest("/login/oauth2/auth") { request in
            guard let redirectUri = request.firstQueryParam(named: "redirect_uri" ) else {
                return .badRequest(nil)
            }
            // login always works
            return .movedTemporarily("\(redirectUri)?code=t")
        },
        .apiRequest(PostLoginOAuthRequest(client: .make(), code: "")) { request in
            APIOAuthToken.make(user: .from(user: request.state.selfUser))
        },
        .apiRequest(DeleteLoginOAuthRequest(session: .make())) { _ in .init() },
        .apiRequest(GetWebSessionRequest(to: nil)) { request in
            .init(session_url: request["return_to"].flatMap { URL(string: $0) } ?? request.baseUrl)
        },

        // MARK: Quiz Submissions
        // https://canvas.instructure.com/doc/api/quiz_submissions.html
        .apiRequest(GetAllQuizSubmissionsRequest(courseID: Pattern.courseID, quizID: Pattern.quizID)) { request in
            let quiz = try lookupQuiz(forRequest: request)
            return GetAllQuizSubmissionsRequest.Response(
                quiz_submissions: quiz.submissions.compactMap { $0.associatedQuizSubmission },
                submissions: quiz.submissions.map { $0.api }
            )
        },

        // MARK: Quizzes
        // https://canvas.instructure.com/doc/api/quizzes.html
        .apiRequest(GetQuizzesRequest(courseID: Pattern.courseID)) { request in
            try lookupCourse(forRequest: request).quizzes.map { $0.api }
        },
        .apiRequest(GetQuizRequest(courseID: Pattern.courseID, quizID: Pattern.quizID)) { request in
            try lookupQuiz(forRequest: request).api
        },

        // MARK: Sections
        // https://canvas.instructure.com/doc/api/sections.html
        .apiRequest(GetCourseSectionsRequest(courseID: Pattern.courseID)) { _ in [] },

        // MARK: Submissions
        // https://canvas.instructure.com/doc/api/submissions.html
        .apiRequest(GetSubmissionSummaryRequest(context: Pattern.courseContext, assignmentID: Pattern.assignmentID)) { request in
            .init(graded: 42, ungraded: 42, not_submitted: 42)
        },
        .apiRequest(GetSubmissionRequest(context: Pattern.courseContext, assignmentID: Pattern.assignmentID, userID: Pattern.userID)) { request in
            try lookupSubmission(forRequest: request).api
        },
        .apiRequest(GetSubmissionsRequest(context: Pattern.courseContext, assignmentID: Pattern.assignmentID)) { request in
            try lookupAssignment(forRequest: request).submissions.map { $0.api }
        },
        .apiRequest(PutSubmissionGradeRequest(courseID: Pattern.courseID, assignmentID: Pattern.assignmentID, userID: Pattern.userID)) { request in
            let submission = try lookupSubmission(forRequest: request)
            guard let body: PutSubmissionGradeRequest.Body = request.body else { return nil }
            if let comment = body.comment {
                if submission.api.submission_comments == nil {
                    submission.api.submission_comments = []
                }
                submission.api.submission_comments!.append(APISubmissionComment.make(
                    id: request.state.nextId().value,
                    author_id: request.state.selfId,
                    author_name: request.state.selfUser.name,
                    author: .make(from: request.state.selfUser),
                    comment: comment.text_comment ?? "",
                    attachments: []
                ))
            }
            if let newSubmission = body.submission {
                submission.api.grade = newSubmission.posted_grade
                submission.api.score = Double(newSubmission.posted_grade ?? "0") ?? 0
                submission.api.graded_at = newSubmission.posted_grade.map { _ in Date() }
            }
            return submission.api
        },
        .graphQLAny(operationName: "SubmissionList") { request in
            guard let variables = request.body["variables"] as? [String: Any],
                  let assignmentID = variables["assignmentID"] as? String else {
                throw ServerError.badRequest
            }
            guard let assignment = request.state.assignment(byId: assignmentID) else { throw ServerError.notFound }
            return assignment.submissionList(state: request.state)
        },

        // MARK: Tabs
        // https://canvas.instructure.com/doc/api/tabs.html
        .apiRequest(GetTabsRequest(context: Pattern.courseContext)) { request in
            try lookupCourse(forRequest: request).tabs
        },

        // MARK: Users
        // https://canvas.instructure.com/doc/api/users.html
        .apiRequest(GetUserProfileRequest(userID: Pattern.userID)) { request in
            let user = try lookupUser(forRequest: request)
            return APIProfile.make(
                id: user.id,
                name: user.name,
                primary_email: user.email,
                login_id: user.login_id,
                avatar_url: user.avatar_url?.rawValue,
                pronouns: user.pronouns
            )
        },
        .apiRequest(GetCustomColorsRequest()) { request in .init(custom_colors: request.state.customColors) },
        .rest("/api/v1/users/self/colors/:id", method: .put) { request in
            let body = try JSONDecoder().decode(UpdateCustomColorRequest.Body.self, from: Data(request.body))
            request.state.customColors[request[":id"]!] = body.hexcode
            return .accepted
        },
        .apiRequest(GetUserSettingsRequest(userID: "self")) { _ in .make() },
        .rest("/api/v1/users/self/custom_data/favorites/groups") { _ in .json([String: String]()) },

        // MARK: Miscellaneous and/or undocumented
        .apiRequest(GetMobileVerifyRequest(domain: "")) { request in
            APIVerifyClient.make(base_url: request.baseUrl)
        },
        .rest("/users/self") { _ in .ok(.htmlBody("")) },
        .apiRequest(GetDashboardCardsRequest()) { request in
                try request.state.userEnrollments().compactMap { enrollment in
                guard let course = request.state.course(byId: enrollment.course_id!)?.api else {
                    throw ServerError.notFound
                }
                guard request.state.favoriteCourses.isEmpty || request.state.favoriteCourses.contains(course.id) else { return nil }
                return APIDashboardCard.make(
                    assetString: course.canvasContextID,
                    courseCode: course.course_code!,
                    enrollmentType: enrollment.type,
                    href: "/courses/\(course.id)",
                    id: course.id,
                    longName: course.name!,
                    originalName: course.name!,
                    position: Int(course.id),
                    shortName: course.name!
                )
            }
        },
        .apiRequest(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"))) { _ in .make() },
        .apiRequest(GetContextPermissionsRequest(context: Pattern.courseContext)) { request in
            let permissions = try lookupCourse(forRequest: request).api.permissions ??
                APICourse.Permissions(create_announcement: false, create_discussion_topic: false)
            return try APIJSONDecoder().decode(APIPermissions.self, from: APIJSONEncoder().encode(permissions))
        },
        .apiRequest(GetExternalToolsRequest(context: Pattern.courseContext, includeParents: false)) { request in
            try lookupCourse(forRequest: request).externalTools
        },
        .apiRequest(GetTodosRequest()) { _ in [] },
        .rest("/api/v1/users/self/todo_item_count") { _ in
            .json(["needs_grading_count": 0, "assignments_needing_submitting": 0])
        },
        .rest("/api/v1/courses/:courseID/lti_apps/launch_definitions") { _ in .json([String]()) },
    ]
}
