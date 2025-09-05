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
    let plannable: APIPlannable.Plannable?
    public let plannable_date: Date
    let submissions: TypeSafeCodable<APIPlannable.Submissions, Bool>?
    public let details: APIPlannable.Details?

    public var plannableType: PlannableType { .init(rawValue: plannable_type) ?? .other }

    public var context: Context? {
        if let context = contextFromContextType() {
            return context
        }
        if PlannableType(rawValue: plannable_type) == .planner_note {
            // Notes have no 'context_type', but have IDs in the inner 'plannable' object
            return contextFromInnerPlannableObject()
        }
        return nil
    }

    private func contextFromContextType() -> Context? {
        guard let raw = context_type, let type = ContextType(rawValue: raw.lowercased()) else {
            return nil
        }
        return switch type {
        case .course: Context(.course, id: course_id?.rawValue)
        case .group: Context(.group, id: group_id?.rawValue)
        case .user: Context(.user, id: user_id?.rawValue)
        default: nil
        }
    }

    private func contextFromInnerPlannableObject() -> Context? {
        // order matters: 'course_id' has precedence over 'user_id'
        return Context(.course, id: self.plannable?.course_id)
            ?? Context(.user, id: self.plannable?.user_id)
    }
}

extension APIPlannable {
    public struct Plannable: Codable, Equatable {
        let title: String?
        let details: String?
        let all_day: Bool?
        let start_at: Date?
        let end_at: Date?
        let course_id: String?
        let user_id: String?
        let points_possible: Double?
        let sub_assignment_tag: String?
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

    public struct Details: Codable, Equatable {
        public let reply_to_entry_required_count: Int?
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
        plannable: APIPlannable.Plannable? = .make(title: "assignment a", details: "description"),
        plannable_date: Date = Clock.now,
        submissions: Submissions? = nil,
        details: APIPlannable.Details? = nil
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
            submissions: TypeSafeCodable(value1: submissions, value2: nil),
            details: details
        )
    }
}

extension APIPlannable.Plannable {
    public static func make(
        title: String? = nil,
        details: String? = nil,
        all_day: Bool? = nil,
        start_at: Date? = nil,
        end_at: Date? = nil,
        course_id: String? = nil,
        user_id: String? = nil,
        points_possible: Double? = nil,
        sub_assignment_tag: String? = nil
    ) -> APIPlannable.Plannable {
        .init(
            title: title,
            details: details,
            all_day: all_day,
            start_at: start_at,
            end_at: end_at,
            course_id: course_id,
            user_id: user_id,
            points_possible: points_possible,
            sub_assignment_tag: sub_assignment_tag
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

extension APIPlannable.Details {
    public static func make(
        reply_to_entry_required_count: Int? = nil
    ) -> APIPlannable.Details {
        .init(
            reply_to_entry_required_count: reply_to_entry_required_count
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

    var userId: String?
    var startDate: Date?
    var endDate: Date?
    var contextCodes: [String] = []
    var filter: String = ""

    public var path: String {
        if let userId {
            return "users/\(userId)/planner/items"
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
            .value("filter", filter)
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
