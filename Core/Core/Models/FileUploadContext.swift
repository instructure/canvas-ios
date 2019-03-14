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

public enum FileUploadContext: RawRepresentable {
    case course(String)
    case user(String)
    case submission(courseID: String, assignmentID: String)

    public static var myFiles: FileUploadContext {
        return .user("self")
    }

    public var rawValue: String {
        switch self {
        case let .course(courseID):
            return "course_\(courseID)"
        case let .user(userID):
            return "user_\(userID)"
        case let .submission(courseID: courseID, assignmentID: assignmentID):
            return "submission_\(courseID)_\(assignmentID)"
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case NSRegularExpression("course_[0-9~]*$"):
            let courseID = String(rawValue.split(separator: "_")[0])
            self = .course(courseID)
        case NSRegularExpression("user_[0-9~]*$"):
            let userID = String(rawValue.split(separator: "_")[0])
            self = .user(userID)
        case NSRegularExpression("submission_[0-9~]*_[0-9~]*$"):
            let components = rawValue.split(separator: "_").map(String.init)
            let courseID = components[1]
            let assignmentID = components[2]
            self = .submission(courseID: courseID, assignmentID: assignmentID)
        default:
            return nil
        }
    }
}
