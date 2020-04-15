//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
    let group_id: ID?
    let user_id: ID?
    let context_type: String?
    let planner_override: APIPlannerOverride?
    let plannable_id: ID
    let plannable_type: String
    let html_url: APIURL?
    let context_image: URL?
    let context_name: String?
    let plannable: plannable?
    public let plannable_date: Date
    //  swiftlint:disable:next type_name
    public struct plannable: Codable, Equatable {
        let title: String?
        let points_possible: Double?
        let details: String?

        public init(title: String? = nil, points_possible: Double? = nil, details: String? = nil) {
            self.title = title
            self.points_possible = points_possible
            self.details = details
        }
    }
}

public struct APIPlannerOverride: Codable, Equatable {
    let id: ID
    let plannable_type: String
    let plannable_id: ID
    let user_id: ID
    let assignment_id: String?
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
        group_id: ID? = nil,
        user_id: ID? = nil,
        context_type: String? = "Course",
        planner_override: APIPlannerOverride? = nil,
        plannable_id: ID = "1",
        plannable_type: String = "Assignment",
        html_url: URL? = URL(string: "http://localhost")!,
        context_image: URL = URL(string: "https://live.staticflickr.com/1449/24823655706_a46286c12e.jpg")!,
        context_name: String? = "Assignment Grades",
        plannable: APIPlannable.plannable? = APIPlannable.plannable(title: "assignment a", details: "description"),
        plannable_date: Date = Clock.now
    ) -> APIPlannable {
        return APIPlannable(
            course_id: course_id,
            group_id: group_id,
            user_id: user_id,
            context_type: context_type,
            planner_override: planner_override,
            plannable_id: plannable_id,
            plannable_type: plannable_type,
            html_url: APIURL(rawValue: html_url),
            context_image: context_image,
            context_name: context_name,
            plannable: plannable,
            plannable_date: plannable_date
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

// https://canvas.instructure.com/doc/api/planner.html#method.planner.index
public struct GetPlannablesRequest: APIRequestable {
    public typealias Response = [APIPlannable]

    var userID: String?
    var startDate: Date?
    var endDate: Date?
    var contextCodes: [String] = []
    var filter: String = ""

    public var path: String {
        if let userID = userID {
            return "users/\(userID)/planner/items"
        } else {
            return "planner/items"
        }
    }

    public var query: [APIQueryItem] {
        [
            .perPage(100),
            .optionalValue("start_date", startDate?.isoString()),
            .optionalValue("end_date", endDate?.isoString()),
            .array("context_codes", contextCodes),
            .value("filter", filter),
        ]
    }
}

// https://canvas.instructure.com/doc/api/planner.html#method.planner_notes.create
public struct PostPlannerNoteRequest: APIRequestable {
    public typealias Response = APINoContent

    public init(body: Body) {
        self.body = body
    }

    public var method: APIMethod = .post

    public var path: String = "planner_notes"

    public let body: Body?

    public struct Body: Codable, Equatable {
        let title: String?
        let details: String?
        let todo_date: Date
        let course_id: String?
        let linked_object_type: Plannable.PlannableType?
        let linked_object_id: String?
    }
}
