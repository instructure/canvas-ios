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
        return CourseNavigationViewController(courseID: courseID)
    },

    RouteHandler(.syllabus(courseID: ":courseID", includeAssignmentPath: false), name: "syllabus") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return SyllabusViewController.create(courseID: courseID)
    },

    RouteHandler(.syllabus(courseID: ":courseID"), name: "syllabus") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return SyllabusViewController.create(courseID: courseID)
    },

    RouteHandler(.course(":courseID", assignment: ":assignmentID"), name: "course_assignment") { url, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return AssignmentDetailsViewController.create(courseID: courseID, assignmentID: assignmentID, fragment: url.fragment)
    },

    RouteHandler(.group(":groupID"), name: "group") {_, params in
        guard let groupID = params["groupID"] else { return nil }
        return GroupNavigationViewController(groupID: groupID)
    },

    RouteHandler(.quizzes(forCourse: ":courseID"), name: "course_quiz") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return QuizListViewController.create(courseID: courseID)
    },

    RouteHandler(.assignments(forCourse: ":courseID"), name: "course_assignments") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return AssignmentListViewController(courseID: courseID)
    },

    RouteHandler(.submission(forCourse: ":courseID", assignment: ":assignmentID", user: ":userID"), name: "submission") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else {
            return nil
        }
        return SubmissionDetailsViewController.create(context: ContextModel(.course, id: courseID), assignmentID: assignmentID, userID: userID)
    },

    RouteHandler(.assignmentFileUpload(courseID: ":courseID", assignmentID: ":assignmentID"), name: "assignment_file_upload") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = AppEnvironment.shared.currentSession?.userID else {
            return nil
        }
        let presenter = SubmissionFilePresenter(courseID: courseID, assignmentID: assignmentID, userID: userID)
        return FilePickerViewController.create(presenter: presenter)
    },

    RouteHandler(.assignmentTextSubmission(courseID: ":courseID", assignmentID: ":assignmentID", userID: ":userID"), name: "assignment_text_submission") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else {
            return nil
        }
        return TextSubmissionViewController.create(courseID: courseID, assignmentID: assignmentID, userID: userID)
    },

    RouteHandler(.assignmentUrlSubmission(courseID: ":courseID", assignmentID: ":assignmentID", userID: ":userID"), name: "assignment_url_submission") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else {
            return nil
        }
        return UrlSubmissionViewController.create(courseID: courseID, assignmentID: assignmentID, userID: userID)
    },

    RouteHandler(.logs, name: "logs") { _, _ in
        return LogEventListViewController.create()
    },
])
