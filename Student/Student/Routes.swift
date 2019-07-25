//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Core

public let router = Router(routes: [
    RouteHandler(.login, name: "login") { _, _ in
        guard let delegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return LoginNavigationController.create(loginDelegate: delegate)
    },

    RouteHandler(.courses, name: "courses") { _, _ in
        return CourseListViewController.create()
    },

    RouteHandler(.course(":courseID"), name: "course") {_, params in
        guard let courseID = params["courseID"] else { return nil }
        return CourseNavigationViewController(courseID: ID.expandTildeID(courseID))
    },

    RouteHandler(.syllabus(courseID: ":courseID", includeAssignmentPath: false), name: "syllabus") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return SyllabusViewController.create(courseID: ID.expandTildeID(courseID))
    },

    RouteHandler(.syllabus(courseID: ":courseID"), name: "syllabus") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return SyllabusViewController.create(courseID: ID.expandTildeID(courseID))
    },

    RouteHandler(.course(":courseID", assignment: ":assignmentID"), name: "course_assignment") { url, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return AssignmentDetailsViewController.create(
            courseID: ID.expandTildeID(courseID),
            assignmentID: ID.expandTildeID(assignmentID),
            fragment: url.fragment
        )
    },

    RouteHandler(.group(":groupID"), name: "group") {_, params in
        guard let groupID = params["groupID"] else { return nil }
        return GroupNavigationViewController(groupID: ID.expandTildeID(groupID))
    },

    RouteHandler(.pages(forCourse: ":courseID"), name: "course_page") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        let context = ContextModel(.course, id: ID.expandTildeID(courseID))
        return PageListViewController.create(context: context)
    },

    RouteHandler(.pages(forGroup: ":groupID"), name: "group_page") { _, params in
        guard let groupID = params["groupID"] else { return nil }
        let context = ContextModel(.group, id: ID.expandTildeID(groupID))
        return PageListViewController.create(context: context)
    },

    RouteHandler(.quizzes(forCourse: ":courseID"), name: "course_quiz") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return QuizListViewController.create(courseID: ID.expandTildeID(courseID))
    },

    RouteHandler(.assignments(forCourse: ":courseID"), name: "course_assignments") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return AssignmentListViewController(courseID: ID.expandTildeID(courseID))
    },

    RouteHandler(.submission(forCourse: ":courseID", assignment: ":assignmentID", user: ":userID"), name: "submission") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else {
            return nil
        }
        return SubmissionDetailsViewController.create(
            context: ContextModel(.course, id: ID.expandTildeID(courseID)),
            assignmentID: ID.expandTildeID(assignmentID),
            userID: ID.expandTildeID(userID)
        )
    },

    RouteHandler(.assignmentTextSubmission(courseID: ":courseID", assignmentID: ":assignmentID", userID: ":userID"), name: "assignment_text_submission") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else {
            return nil
        }
        return TextSubmissionViewController.create(
            courseID: ID.expandTildeID(courseID),
            assignmentID: ID.expandTildeID(assignmentID),
            userID: ID.expandTildeID(userID)
        )
    },

    RouteHandler(.assignmentUrlSubmission(courseID: ":courseID", assignmentID: ":assignmentID", userID: ":userID"), name: "assignment_url_submission") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else {
            return nil
        }
        return UrlSubmissionViewController.create(
            courseID: ID.expandTildeID(courseID),
            assignmentID: ID.expandTildeID(assignmentID),
            userID: ID.expandTildeID(userID)
        )
    },

    RouteHandler(.logs, name: "logs") { _, _ in
        return LogEventListViewController.create()
    },

    RouteHandler(.actAsUser, name: "act_as_user") { _, _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },

    RouteHandler(.actAsUserID(":userID"), name: "act_as_user") { _, params in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate, userID: params["userID"])
    },
])
