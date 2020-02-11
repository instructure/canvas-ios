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

public struct APIPlannable: Codable, Equatable {
    let course_id: ID?
    let context_type: String
    let planner_override: APIPlannerOverride?
    let plannable_id: ID
    let plannable_type: String
    let html_url: URL
    let context_image: URL
}

public struct APIPlannerOverride: Codable, Equatable {
    let id: ID
    let plannable_type: String
    let plannable_id: ID
    let user_id: ID
    let assignment_id: String
    let workflow_state: String
    let marked_complete: Bool
    let dismissed: Bool
    let created_at: Date
    let updated_at: Date?
    let deleted_at: Date?
}

#if DEBUG
extension APIPlannable {
    public static func make(
        course_id: ID? = "1",
        context_type: String = "course",
        planner_override: APIPlannerOverride? = nil,
        plannable_id: ID = "1",
        plannable_type: String = "Assignment",
        html_url: URL = URL(string: "http://localhost")!,
        context_image: URL = URL(string: "https://live.staticflickr.com/1449/24823655706_a46286c12e.jpg")!
    ) -> APIPlannable {
        return APIPlannable(
            course_id: course_id,
            context_type: context_type,
            planner_override: planner_override,
            plannable_id: plannable_id,
            plannable_type: plannable_type,
            html_url: html_url,
            context_image: context_image
        )
    }
}

extension APIPlannerOverride {
    public static func make(
        id: ID = "1",
        plannable_type: String = "Assignment",
        plannable_id: ID = "1",
        user_id: ID = "1",
        assignment_id: String = "1",
        workflow_state: String = "published",
        marked_complete: Bool = false,
        dismissed: Bool = false,
        created_at: Date = Date().addYears(-1),
        updated_at: Date = Date().addYears(-1),
        deleted_at: Date? = nil
    ) -> APIPlannerOverride {
        return APIPlannerOverride(
            id: id,
            plannable_type: plannable_type,
            plannable_id: plannable_id,
            user_id: user_id,
            assignment_id: assignment_id,
            workflow_state: workflow_state,
            marked_complete: marked_complete,
            dismissed: dismissed,
            created_at: created_at,
            updated_at: updated_at,
            deleted_at: deleted_at
        )
    }
}

#endif
