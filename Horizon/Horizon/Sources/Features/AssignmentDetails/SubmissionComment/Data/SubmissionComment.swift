//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Foundation

struct SubmissionComment: Identifiable {
    let id: String
    let assignmentID: String
    let attempt: Int?
    let authorID: String?
    let authorName: String
    let comment: String
    let createdAt: Date?
    let isCurrentUsersComment: Bool
    
    var createdAtString: String? {
        if let createdAt {
            return Self.dateFormatter.string(from: createdAt)
        } else {
            return nil
        }
    }

    var attemptString: String? {
        if let attempt {
            return String(attempt)
        } else {
            return nil
        }
    }

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    init(from entity: Core.SubmissionComment, isCurrentUsersComment: Bool) {
        self.id = entity.id
        self.assignmentID = entity.assignmentID
        self.attempt = entity.attempt
        self.authorID = entity.authorID
        self.authorName = entity.authorName
        self.comment = entity.comment
        self.createdAt = entity.createdAt
        self.isCurrentUsersComment = isCurrentUsersComment
    }

    init(
        id: String,
        assignmentID: String,
        attempt: Int?,
        authorID: String?,
        authorName: String,
        comment: String,
        createdAt: Date?,
        isCurrentUsersComment: Bool
    ) {
        self.id = id
        self.assignmentID = assignmentID
        self.attempt = attempt
        self.authorID = authorID
        self.authorName = authorName
        self.comment = comment
        self.createdAt = createdAt
        self.isCurrentUsersComment = isCurrentUsersComment
    }
}
