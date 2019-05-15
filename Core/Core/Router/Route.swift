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

import Foundation

public struct Route: Equatable {
    public let url: URLComponents

    init(_ path: String) {
        url = .parse(path)
    }

    public static let login = Route("/login")

    public static let courses = Route("/courses")

    public static func course(_ courseID: String) -> Route {
        return Route("/courses/\(courseID)")
    }

    public static func course(_ courseID: String, user userID: String) -> Route {
        return Route("/courses/\(courseID)/users/\(userID)")
    }

    public static func course(_ courseID: String, assignment assignmentID: String) -> Route {
        return Route("/courses/\(courseID)/assignments/\(assignmentID)")
    }

    public static func assignments(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/assignments")
    }

    public static func submission(forCourse courseID: String, assignment assignmentID: String, user userID: String) -> Route {
        return Route("/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(userID)")
    }

    public static func assignmentTextSubmission(courseID: String, assignmentID: String, userID: String) -> Route {
        return Route("/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(userID)/online_text_entry")
    }

    public static func assignmentUrlSubmission(courseID: String, assignmentID: String, userID: String) -> Route {
        return Route("/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(userID)/urlsubmission")
    }

    public static func syllabus(courseID: String, includeAssignmentPath: Bool = true) -> Route {
        return Route("/courses/\(courseID)\(includeAssignmentPath ? "/assignments" : "")/syllabus")
    }

    public static let groups = Route("/groups")

    public static func group(_ groupID: String) -> Route {
        return Route("/groups/\(groupID)")
    }

    public static func quizzes(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/quizzes")
    }

    public static let profileObservees = Route("/profile/observees")

    public static let logs = Route("/logs")

    public static func modules(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/modules")
    }

    public static func module(forCourse courseID: String, moduleID: String) -> Route {
        return Route("/courses/\(courseID)/modules/\(moduleID)")
    }

    public static func sendSupport(forType type: String) -> Route {
        return Route("/support/\(type)")
    }

    public static let developerMenu = Route("/dev-menu")

    public static func termsOfService(forAccount accountID: String) -> Route {
        return Route("/accounts/\(accountID)/terms_of_service")
    }

    public static let actAsUser = Route("/act-as-user")

    public static func actAsUserID(_ id: String) -> Route {
        return Route("/act-as-user/\(id)")
    }

    public static let wrongApp = Route("/wrong-app")

    public static let anythingElse = Route("*")
}
