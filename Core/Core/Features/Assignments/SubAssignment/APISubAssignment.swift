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

public struct APISubAssignment: Codable, Equatable {
    let id: ID
    let course_id: ID
    let submission_types: [SubmissionType]
    let sub_assignment_tag: String?
    let discussion_topic: APIDiscussionTopic?
    let html_url: URL?
}

#if DEBUG
extension APISubAssignment {
    public static func make(
        id: ID = "1",
        course_id: ID = "1",
        submission_types: [SubmissionType] = [.discussion_topic],
        sub_assignment_tag: String? = nil,
        discussion_topic: APIDiscussionTopic? = nil,
        html_url: URL? = nil
    ) -> APISubAssignment {
        return APISubAssignment(
            id: id,
            course_id: course_id,
            submission_types: submission_types,
            sub_assignment_tag: sub_assignment_tag,
            discussion_topic: discussion_topic,
            html_url: html_url
        )
    }
}

#endif
