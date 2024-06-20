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
    let context_name: String?
    let plannable: plannable?
    public let plannable_date: Date
    let submissions: TypeSafeCodable<Submissions, Bool>?

    //  swiftlint:disable:next type_name
    public struct plannable: Codable, Equatable {
        let all_day: Bool?
        let course_id: String?
        let details: String?
        let end_at: Date?
        let points_possible: Double?
        let start_at: Date?
        let title: String?
        let user_id: String?

        public init(
            all_day: Bool? = nil,
            course_id: String? = nil,
            details: String? = nil,
            end_at: Date? = nil,
            points_possible: Double? = nil,
            start_at: Date? = nil,
            title: String? = nil,
            user_id: String? = nil
        ) {
            self.all_day = all_day
            self.course_id = course_id
            self.details = details
            self.end_at = end_at
            self.points_possible = points_possible
            self.start_at = start_at
            self.title = title
            self.user_id = user_id
        }
    }

    public struct Submissions: Codable, Equatable {
        let submitted: Bool?
        let excused: Bool?
        let graded: Bool?
        let late: Bool?
        let missing: Bool?
        let needs_grading: Bool?
        let has_feedback: Bool?
        let redo_request: Bool?
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
        context_name: String? = "Assignment Grades",
        plannable: APIPlannable.plannable? = APIPlannable.plannable(details: "description", title: "assignment a"),
        plannable_date: Date = Clock.now,
        submissions: Submissions? = nil
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
            context_name: context_name,
            plannable: plannable,
            plannable_date: plannable_date,
            submissions: TypeSafeCodable(value1: submissions, value2: nil)
        )
    }
}

extension APIPlannable.Submissions {
    public static func make(
        submitted: Bool? = false,
        excused: Bool? = false,
        graded: Bool? = false,
        late: Bool? = false,
        missing: Bool? = false,
        needs_grading: Bool? = false,
        has_feedback: Bool? = false,
        redo_request: Bool? = false
    ) -> APIPlannable.Submissions {
        return APIPlannable.Submissions(
            submitted: submitted,
            excused: excused,
            graded: graded,
            late: late,
            missing: missing,
            needs_grading: needs_grading,
            has_feedback: has_feedback,
            redo_request: redo_request)
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

// https://canvas.instructure.com/doc/api/planner.html#method.planner_overrides.update
public struct UpdatePlannerOverrideRequest: APIRequestable {
    public typealias Response = APINoContent
    public struct Body: Codable, Equatable {
        let marked_complete: Bool
    }
    public var method: APIMethod = .put
    public var path: String { "planner/overrides/\(overrideId)" }
    public let body: Body?

    private let overrideId: String

    public init(overrideId: String, body: Body) {
        self.overrideId = overrideId
        self.body = body
    }
}

// https://canvas.instructure.com/doc/api/planner.html#method.planner_overrides.create
public struct CreatePlannerOverrideRequest: APIRequestable {
    public typealias Response = APIPlannerOverride
    public struct Body: Codable, Equatable {
        let plannable_type: String
        let plannable_id: String
        let marked_complete: Bool
    }
    public var method: APIMethod = .post
    public var path: String { "planner/overrides" }
    public let body: Body?

    public init(body: Body) {
        self.body = body
    }
}
