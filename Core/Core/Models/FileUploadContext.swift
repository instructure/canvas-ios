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

import Foundation

public enum FileUploadContext: Codable {
    enum CodingKeys: String, CodingKey {
        case type, userID, courseID, assignmentID, comment
    }

    enum Key: String, Codable {
        case course, user, submission, submissionComment
    }

    case course(String)
    case user(String)
    case submission(courseID: String, assignmentID: String, comment: String?)
    case submissionComment(courseID: String, assignmentID: String)

    public static var myFiles: FileUploadContext {
        return .user("self")
    }

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.container(keyedBy: CodingKeys.self)
        let type = try decoder.decode(Key.self, forKey: .type)
        switch type {
        case .course:
            let courseID = try decoder.decode(String.self, forKey: .courseID)
            self = .course(courseID)
        case .user:
            let userID = try decoder.decode(String.self, forKey: .userID)
            self = .user(userID)
        case .submission:
            let courseID = try decoder.decode(String.self, forKey: .courseID)
            let assignmentID = try decoder.decode(String.self, forKey: .assignmentID)
            let comment = try decoder.decodeIfPresent(String.self, forKey: .comment)
            self = .submission(courseID: courseID, assignmentID: assignmentID, comment: comment)
        case .submissionComment:
            let courseID = try decoder.decode(String.self, forKey: .courseID)
            let assignmentID = try decoder.decode(String.self, forKey: .assignmentID)
            self = .submissionComment(courseID: courseID, assignmentID: assignmentID)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .course(courseID):
            try container.encode(Key.course, forKey: .type)
            try container.encode(courseID, forKey: .courseID)
        case let .user(userID):
            try container.encode(Key.user, forKey: .type)
            try container.encode(userID, forKey: .userID)
        case let .submission(courseID, assignmentID, comment):
            try container.encode(Key.submission, forKey: .type)
            try container.encode(courseID, forKey: .courseID)
            try container.encode(assignmentID, forKey: .assignmentID)
            try container.encodeIfPresent(comment, forKey: .comment)
        case let .submissionComment(courseID, assignmentID):
            try container.encode(Key.submissionComment, forKey: .type)
            try container.encode(courseID, forKey: .courseID)
            try container.encode(assignmentID, forKey: .assignmentID)
        }
    }
}
