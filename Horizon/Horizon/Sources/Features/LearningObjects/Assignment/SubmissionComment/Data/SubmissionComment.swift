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
    let attempt: Int?
    let authorID: String?
    let authorName: String
    let comment: String
    let createdAt: Date?
    let isCurrentUsersComment: Bool
    let isRead: Bool

    var createdAtString: String? {
        if let createdAt {
            return Self.dateFormatter.string(from: createdAt)
        } else {
            return nil
        }
    }

    var attemptString: String? {
        if let attempt, attempt > 0 {
            let attemptKey = String(localized: "Attempt", bundle: .horizon)
            return String("\(attemptKey) \(attempt)")
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

    init(
        from entity: Core.CDSubmissionComment,
        isCurrentUsersComment: Bool
    ) {
        self.id = entity.id
        self.attempt = entity.attempt
        self.authorID = entity.authorID
        self.authorName = entity.authorName ?? ""
        self.comment = entity.comment ?? ""
        self.createdAt = entity.createdAt
        self.isCurrentUsersComment = isCurrentUsersComment
        self.isRead = entity.isRead
    }

    init(
        id: String,
        attempt: Int?,
        authorID: String?,
        authorName: String,
        comment: String,
        createdAt: Date?,
        isCurrentUsersComment: Bool,
        isRead: Bool = true
    ) {
        self.id = id
        self.attempt = attempt
        self.authorID = authorID
        self.authorName = authorName
        self.comment = comment
        self.createdAt = createdAt
        self.isCurrentUsersComment = isCurrentUsersComment
        self.isRead = isRead
    }
}
