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
    private static let courseRouteContext = ContextModel(.course, id: ":courseID")

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
        .apiRequest(GetAssignmentGroupsRequest(courseID: ":courseID")) { request in
            request.state.course(byId: request[":courseID"])?.assignmentGroups
        },

        // MARK: Assignments
        // https://canvas.instructure.com/doc/api/assignments.html
        .apiRequest(GetAssignmentsRequest(courseID: ":courseID")) { request in
            request.state.course(byId: request[":courseID"])?.assignments.map { $0.api }
        },
        .apiRequest(GetAssignmentRequest(courseID: ":courseID", assignmentID: ":assignmentID", include: [])) { request in
            request.state.course(byId: request[":courseID"])?.assignment(byId: request[":assignmentID"])?.api
        },
        .graphQL(AssignmentListRequestable.self) { request in
            let vars = request.body.variables
            guard let course = request.state.course(byId: vars.courseID) else {
                throw ServerError.notFound
            }
            let assignments: [APIAssignmentListAssignment] = course.assignments.map { assignment in
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
            return APIAssignmentListResponse.make(gradingPeriods: [], groups: [.make(assignments: assignments)])
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
        .apiRequest(GetCourseRequest(courseID: ":courseID")) { request in
            request.state.course(byId: request[":courseID"]!)?.api
        },

        // MARK: Enrollments
        // https://canvas.instructure.com/doc/api/enrollments.html
        .apiRequest(GetEnrollmentsRequest(context: ContextModel.currentUser)) { request in
            request.state.userEnrollments()
        },
        .apiRequest(GetEnrollmentsRequest(context: courseRouteContext)) { request in
            request.state.enrollments.filter { $0.course_id == request[":courseID"]! }
        },

        // MARK: Feature Flags
        // https://canvas.instructure.com/doc/api/feature_flags.html
        .apiRequest(GetEnabledFeatureFlagsRequest(context: courseRouteContext)) { request in
            request.state.course(byId: request[":courseID"])?.featureFlags
        },

        // MARK: Grading Periods
        // https://canvas.instructure.com/doc/api/grading_periods.html
        .apiRequest(GetGradingPeriodsRequest(courseID: ":courseID")) { request in
            request.state.course(byId: request[":courseID"])?.gradingPeriods
        },

        // MARK: Groups
        // https://canvas.instructure.com/doc/api/groups.html
        .apiRequest(GetGroupsRequest(context: ContextModel.currentUser)) { _ in [] },
        .apiRequest(GetGroupsRequest(context: courseRouteContext)) { _ in [] },

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

        // MARK: Submissions
        // https://canvas.instructure.com/doc/api/submissions.html
        .apiRequest(GetSubmissionSummaryRequest(context: courseRouteContext, assignmentID: ":assignmentID")) { request in
            .init(graded: 42, ungraded: 42, not_submitted: 42)
        },
        .apiRequest(GetSubmissionRequest(context: courseRouteContext, assignmentID: ":assignmentID", userID: ":userID")) { request in
            guard let course = request.state.course(byId: request[":courseID"]!),
                  let assignment = request.state.assignment(byId: request[":assignmentID"]!) else {
                throw ServerError.notFound
            }
            return assignment.submissions.first { $0.user_id.value == request[":userID"]! }
        },
        .apiRequest(GetSubmissionsRequest(context: courseRouteContext, assignmentID: ":assignmentID")) { request in
            guard let course = request.state.course(byId: request[":courseID"]!),
                  let assignment = request.state.assignment(byId: request[":assignmentID"]!) else {
                throw ServerError.notFound
            }
            return assignment.submissions
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
        .apiRequest(GetTabsRequest(context: courseRouteContext)) { request in
            request.state.course(byId: request[":courseID"]!)?.tabs
        },

        // MARK: Users
        // https://canvas.instructure.com/doc/api/users.html
        .apiRequest(GetUserProfileRequest(userID: ":userID")) { request in
            var userID = request[":userID"]!
            if userID == "self" {
                userID = request.state.selfId
            }
            guard let user = request.state.user(byId: userID) else { return nil }
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
                guard request.state.favoriteCourses.contains(course.id) else { return nil }
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
        .apiRequest(GetContextPermissionsRequest(context: courseRouteContext)) { request in
            guard let course = request.state.course(byId: request[":courseID"]!) else {
                throw ServerError.notFound
            }
            let permissions = course.api.permissions ?? APICourse.Permissions(create_announcement: false, create_discussion_topic: false)
            return try APIJSONDecoder().decode(APIPermissions.self, from: APIJSONEncoder().encode(permissions))
        },
        .apiRequest(GetExternalToolsRequest(context: courseRouteContext, includeParents: false)) { request in
            request.state.course(byId: request[":courseID"]!)?.externalTools
        },
        .apiRequest(GetTodosRequest()) { _ in [] },
        .rest("/api/v1/users/self/todo_item_count") { _ in
            .json(["needs_grading_count": 0, "assignments_needing_submitting": 0])
        },
        .rest("/api/v1/courses/:courseID/lti_apps/launch_definitions") { _ in .json([String]()) },
    ]
}
