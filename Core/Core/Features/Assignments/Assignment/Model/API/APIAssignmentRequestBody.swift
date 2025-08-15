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

import Foundation

struct APIAssignmentRequestBody: Codable, Equatable {

    struct Assignment: Codable, Equatable {
        // let allowed_extensions: [String]?
        let assignment_overrides: [APIAssignmentOverride]?
        let description: String?
        let due_at: Date?
        let grading_type: GradingType?
        let lock_at: Date?
        let name: String?
        let only_visible_to_overrides: Bool?
        let points_possible: Double?
        let published: Bool?
        // let submission_types: [SubmissionType]?
        let unlock_at: Date?

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(assignment_overrides, forKey: .assignment_overrides)
            try container.encodeIfPresent(description, forKey: .description)
            try container.encode(due_at, forKey: .due_at) // encode null to unset
            try container.encodeIfPresent(grading_type, forKey: .grading_type)
            try container.encode(lock_at, forKey: .lock_at) // encode null to unset
            try container.encodeIfPresent(name, forKey: .name)
            try container.encodeIfPresent(only_visible_to_overrides, forKey: .only_visible_to_overrides)
            try container.encode(points_possible, forKey: .points_possible)
            try container.encodeIfPresent(published, forKey: .published)
            try container.encode(unlock_at, forKey: .unlock_at) // encode null to unset
        }
    }

    let assignment: Assignment
}

#if DEBUG

extension APIAssignmentRequestBody {
    static func make(
        assignment_overrides: [APIAssignmentOverride]? = nil,
        description: String? = nil,
        due_at: Date? = nil,
        grading_type: GradingType? = nil,
        lock_at: Date? = nil,
        name: String? = nil,
        only_visible_to_overrides: Bool? = nil,
        points_possible: Double? = nil,
        published: Bool? = nil,
        unlock_at: Date? = nil
    ) -> APIAssignmentRequestBody {
        .init(
            assignment: .init(
                assignment_overrides: assignment_overrides,
                description: description,
                due_at: due_at,
                grading_type: grading_type,
                lock_at: lock_at,
                name: name,
                only_visible_to_overrides: only_visible_to_overrides,
                points_possible: points_possible,
                published: published,
                unlock_at: unlock_at
            )
        )
    }
}

#endif
