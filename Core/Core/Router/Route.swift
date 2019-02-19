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

    public static func assignmentFileUpload(courseID: String, assignmentID: String) -> Route {
        return Route("/courses/\(courseID)/assignments/\(assignmentID)/fileupload")
    }

    public static func assignmentUrlSubmission(courseID: String, assignmentID: String, userID: String) -> Route {
        return Route("/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(userID)/urlsubmission")
    }

    public static let groups = Route("/groups")

    public static func group(_ groupID: String) -> Route {
        return Route("/groups/\(groupID)")
    }

    public static func quizzes(forCourse courseID: String) -> Route {
        return Route("/courses/\(courseID)/quizzes")
    }

    public static let logs = Route("/logs")
}
