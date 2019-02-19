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
    RouteHandler(.login) { _, _ in
        guard let delegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return LoginNavigationController.create(loginDelegate: delegate)
    },

    RouteHandler(.courses) { _, _ in
        return CourseListViewController.create()
    },

    RouteHandler(.course(":courseID")) {_, params in
        guard let courseID = params["courseID"] else { return nil }
        return CourseNavigationTableViewController(courseID: courseID)
    },

    RouteHandler(.course(":courseID", assignment: ":assignmentID")) { url, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return AssignmentDetailsViewController.create(courseID: courseID, assignmentID: assignmentID, fragment: url.fragment)
    },

    RouteHandler(.group(":groupID")) {_, params in
        guard let groupID = params["groupID"] else { return nil }
        return GroupNavigationTableViewController(groupID: groupID)
    },

    RouteHandler(.quizzes(forCourse: ":courseID")) { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return QuizListViewController.create(courseID: courseID)
    },

    RouteHandler(.assignments(forCourse: ":courseID")) { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return AssignmentListViewController(courseID: courseID)
    },

    RouteHandler(.submission(forCourse: ":courseID", assignment: ":assignmentID", user: ":userID")) { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else {
            return nil
        }
        return SubmissionDetailsViewController.create(context: ContextModel(.course, id: courseID), assignmentID: assignmentID, userID: userID)
    },

    RouteHandler(.assignmentFileUpload(courseID: ":courseID", assignmentID: ":assignmentID")) { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = Keychain.currentSession?.userID else {
            return nil
        }
        let presenter = SubmissionFilePresenter(courseID: courseID, assignmentID: assignmentID, userID: userID)
        return FilePickerViewController.create(presenter: presenter)
    },

    RouteHandler(.assignmentUrlSubmission(courseID: ":courseID", assignmentID: ":assignmentID", userID: ":userID")) { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else {
            return nil
        }
        return UrlSubmissionViewController.create(courseID: courseID, assignmentID: assignmentID, userID: userID)
    },

    RouteHandler(.logs) { _, _ in
        return LogEventListViewController.create()
    },
])
