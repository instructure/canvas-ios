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

public enum FileUploadContext: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case type, context, courseID, assignmentID, userID, comment
    }

    enum Key: String, Codable {
        case context, submission, submissionComment
    }

    case context(Context)
    case submission(courseID: String, assignmentID: String, comment: String?)
    case submissionComment(courseID: String, assignmentID: String, userID: String)

    public static var myFiles: FileUploadContext {
        return .context(Context.currentUser)
    }

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.container(keyedBy: CodingKeys.self)
        let type = try decoder.decode(Key.self, forKey: .type)
        switch type {
        case .context:
            let context = try decoder.decode(Context.self, forKey: .context)
            self = .context(context)
        case .submission:
            let courseID = try decoder.decode(String.self, forKey: .courseID)
            let assignmentID = try decoder.decode(String.self, forKey: .assignmentID)
            let comment = try decoder.decodeIfPresent(String.self, forKey: .comment)
            self = .submission(courseID: courseID, assignmentID: assignmentID, comment: comment)
        case .submissionComment:
            let courseID = try decoder.decode(String.self, forKey: .courseID)
            let assignmentID = try decoder.decode(String.self, forKey: .assignmentID)
            let userID = try decoder.decode(String.self, forKey: .userID)
            self = .submissionComment(courseID: courseID, assignmentID: assignmentID, userID: userID)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .context(context):
            try container.encode(Key.context, forKey: .type)
            try container.encode(Context(context.contextType, id: context.id), forKey: .context)
        case let .submission(courseID, assignmentID, comment):
            try container.encode(Key.submission, forKey: .type)
            try container.encode(courseID, forKey: .courseID)
            try container.encode(assignmentID, forKey: .assignmentID)
            try container.encodeIfPresent(comment, forKey: .comment)
        case let .submissionComment(courseID, assignmentID, userID):
            try container.encode(Key.submissionComment, forKey: .type)
            try container.encode(courseID, forKey: .courseID)
            try container.encode(assignmentID, forKey: .assignmentID)
            try container.encode(userID, forKey: .userID)
        }
    }
}
