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

// https://canvas.instructure.com/doc/api/assignments.html#Assignment
public struct APIAssignment: Codable, Equatable {
    let allowed_attempts: Int?
    let allowed_extensions: [String]?
    let all_dates: [APIAssignmentDate]?
    let annotatable_attachment_id: String?
    let anonymize_students: Bool?
    let anonymous_submissions: Bool?
    let assignment_group_id: ID?
    let can_submit: Bool?
    let course_id: ID
    let course: APICourse?
    let description: String?
    let discussion_topic: APIDiscussionTopic?
    let due_at: Date?
    let external_tool_tag_attributes: APIExternalToolTagAttributes?
    let grade_group_students_individually: Bool?
    let grading_type: GradingType
    let group_category_id: ID?
    let has_overrides: Bool?
    var html_url: URL
    let id: ID
    let locked_for_user: Bool?
    let lock_at: Date?
    let lock_explanation: String?
    let moderated_grading: Bool?
    let name: String
    let needs_grading_count: Int?
    let only_visible_to_overrides: Bool?
    let overrides: [APIAssignmentOverride]?
    let planner_override: APIPlannerOverride?
    let points_possible: Double?
    let position: Int?
    let published: Bool?
    let quiz_id: ID?
    var rubric: [APIRubric]?
    var rubric_settings: APIRubricSettings?
    let score_statistics: APIAssignmentScoreStatistics?
    var submission: APIList<APISubmission>?
    let submission_types: [SubmissionType]
    let unlock_at: Date?
    let unpublishable: Bool?
    let url: URL?
    let use_rubric_for_grading: Bool?

    /** This also returns true if the assignment is locked by date, so there's no need to manually check the `lock_at` and `unlock_at` parameters. */
    public var isLockedForUser: Bool { locked_for_user ?? false }
}

// https://canvas.instructure.com/doc/api/assignments.html#AssignmentDate
public struct APIAssignmentDate: Codable, Equatable {
    let id: ID?
    let base: Bool?
    let title: String?
    let due_at: Date?
    let unlock_at: Date?
    let lock_at: Date?
}

// https://canvas.instructure.com/doc/api/assignments.html#AssignmentOverride
public struct APIAssignmentOverride: Codable, Equatable {
    let assignment_id: ID
    let course_section_id: ID?
    let due_at: Date?
    let group_id: ID?
    let id: ID
    let lock_at: Date?
    let student_ids: [ID]?
    let title: String
    let unlock_at: Date?
}

// https://canvas.instructure.com/doc/api/assignments.html#ExternalToolTagAttributes
public struct APIExternalToolTagAttributes: Codable, Equatable {
    let content_id: ID? // undocumented
}

public struct APIAssignmentScoreStatistics: Codable, Equatable {
    let mean: Double
    let min: Double
    let max: Double
}

#if DEBUG
extension APIAssignment {
    public static func make(
        allowed_attempts: Int? = -1,
        allowed_extensions: [String]? = nil,
        all_dates: [APIAssignmentDate]? = nil,
        annotatable_attachment_id: String? = nil,
        anonymize_students: Bool? = nil,
        anonymous_submissions: Bool? = nil,
        assignment_group_id: ID? = nil,
        can_submit: Bool? = true,
        course_id: ID = "1",
        course: APICourse? = nil,
        description: String? = "<p>Do the following:</p>...",
        discussion_topic: APIDiscussionTopic? = nil,
        due_at: Date? = nil,
        external_tool_tag_attributes: APIExternalToolTagAttributes? = nil,
        grade_group_students_individually: Bool? = nil,
        grading_type: GradingType = .points,
        group_category_id: String? = nil,
        has_overrides: Bool? = false,
        html_url: URL? = nil,
        id: ID = "1",
        locked_for_user: Bool? = false,
        lock_at: Date? = nil,
        lock_explanation: String? = nil,
        moderated_grading: Bool? = nil,
        name: String = "some assignment",
        needs_grading_count: Int = 1,
        only_visible_to_overrides: Bool? = false,
        overrides: [APIAssignmentOverride]? = nil,
        planner_override: APIPlannerOverride? = nil,
        points_possible: Double? = 10,
        position: Int? = 0,
        published: Bool? = true,
        quiz_id: ID? = nil,
        rubric: [APIRubric]? = nil,
        rubric_settings: APIRubricSettings? = .make(),
        score_statistics: APIAssignmentScoreStatistics? = nil,
        submission: APISubmission? = .make(submitted_at: nil, workflow_state: .unsubmitted),
        submissions: [APISubmission]? = nil,
        submission_types: [SubmissionType] = [.online_text_entry],
        unlock_at: Date? = nil,
        unpublishable: Bool? = true,
        url: URL? = nil,
        use_rubric_for_grading: Bool? = nil
    ) -> APIAssignment {

        var submissionList: APIList<APISubmission>?
        if let submissions = submissions, submissions.count > 0 {
            submissionList = APIList<APISubmission>(values: submissions)
        } else if let submission = submission {
            submissionList = APIList<APISubmission>( submission )
        }

        return APIAssignment(
            allowed_attempts: allowed_attempts,
            allowed_extensions: allowed_extensions,
            all_dates: all_dates,
            annotatable_attachment_id: annotatable_attachment_id,
            anonymize_students: anonymize_students,
            anonymous_submissions: anonymous_submissions,
            assignment_group_id: assignment_group_id,
            can_submit: can_submit,
            course_id: course_id,
            course: course,
            description: description,
            discussion_topic: discussion_topic,
            due_at: due_at,
            external_tool_tag_attributes: external_tool_tag_attributes,
            grade_group_students_individually: grade_group_students_individually,
            grading_type: grading_type,
            group_category_id: ID(group_category_id),
            has_overrides: has_overrides,
            html_url: html_url ?? URL(string: "/courses/\(course_id)/assignments/\(id)")!,
            id: id,
            locked_for_user: locked_for_user,
            lock_at: lock_at,
            lock_explanation: lock_explanation,
            moderated_grading: moderated_grading,
            name: name,
            needs_grading_count: needs_grading_count,
            only_visible_to_overrides: only_visible_to_overrides,
            overrides: overrides,
            planner_override: planner_override,
            points_possible: points_possible,
            position: position,
            published: published,
            quiz_id: quiz_id,
            rubric: rubric,
            rubric_settings: rubric_settings,
            score_statistics: score_statistics,
            submission: submissionList,
            submission_types: submission_types,
            unlock_at: unlock_at,
            unpublishable: unpublishable,
            url: url,
            use_rubric_for_grading: use_rubric_for_grading
        )
    }
}

extension APIAssignmentDate {
    public static func make(
        id: ID? = nil,
        base: Bool? = true,
        title: String? = nil,
        due_at: Date? = nil,
        unlock_at: Date? = nil,
        lock_at: Date? = nil
    ) -> APIAssignmentDate {
        return APIAssignmentDate(
            id: id,
            base: base,
            title: title,
            due_at: due_at,
            unlock_at: unlock_at,
            lock_at: lock_at
        )
    }
}

extension APIAssignmentOverride {
    public func make(
        assignment_id: ID,
        course_section_id: ID?,
        due_at: Date?,
        group_id: ID?,
        id: ID,
        lock_at: Date?,
        student_ids: [ID]?,
        title: String,
        unlock_at: Date?
    ) -> APIAssignmentOverride {
        APIAssignmentOverride(
            assignment_id: assignment_id,
            course_section_id: course_section_id,
            due_at: due_at,
            group_id: group_id,
            id: id,
            lock_at: lock_at,
            student_ids: student_ids,
            title: title,
            unlock_at: unlock_at
        )
    }
}

extension APIExternalToolTagAttributes {
    public static func make(content_id: ID? = nil) -> Self {
        return Self(content_id: content_id)
    }
}
extension APIAssignmentScoreStatistics {
    public static func make(
        mean: Double = 2.0,
        min: Double = 1.0,
        max: Double = 5.0
    ) -> APIAssignmentScoreStatistics {
        return APIAssignmentScoreStatistics(
            mean: mean,
            min: min,
            max: max
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.show
public struct GetAssignmentRequest: APIRequestable {
    public typealias Response = APIAssignment

    let courseID: String
    let assignmentID: String
    let include: [GetAssignmentInclude]
    let allDates: Bool?

    init(courseID: String, assignmentID: String, allDates: Bool? = nil, include: [GetAssignmentInclude]) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.include = include
        self.allDates = allDates
    }

    public enum GetAssignmentInclude: String, CaseIterable {
        case submission, overrides, score_statistics, can_submit, observed_users
    }

    public var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        var include = self.include
        include.append(.can_submit)
        query.append(.array("include", include.map { $0.rawValue }))
        if AppEnvironment.shared.app == .teacher || allDates == true {
            query.append(.value("all_dates", "true"))
        }
        return query
    }
}

struct APIAssignmentParameters: Codable, Equatable {
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

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.create
struct PostAssignmentRequest: APIRequestable {
    typealias Response = APIAssignment
    struct Body: Codable, Equatable {
        let assignment: APIAssignmentParameters
    }

    let courseID: String

    let method = APIMethod.post
    var path: String { "\(Context(.course, id: courseID).pathComponent)/assignments" }
    let body: Body?
}

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.update
struct PutAssignmentRequest: APIRequestable {
    typealias Response = APIAssignment
    typealias Body = PostAssignmentRequest.Body

    let courseID: String
    let assignmentID: String

    var method: APIMethod { .put }
    var path: String { "courses/\(courseID)/assignments/\(assignmentID)" }
    let body: Body?
}

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.index
public struct GetAssignmentsRequest: APIRequestable {
    public enum OrderBy: String {
        case position, name
    }

    public enum Include: String {
        case overrides
        case discussion_topic
        case observed_users
        case submission
        case all_dates
        case score_statistics
    }

    public typealias Response = [APIAssignment]

    let courseID: String
    let assignmentGroupID: String?
    let orderBy: OrderBy?
    let assignmentIDs: [String]?
    let include: [Include]
    let perPage: Int?

    public init(
        courseID: String,
        assignmentGroupID: String? = nil,
        orderBy: OrderBy? = .position,
        assignmentIDs: [String]? = nil,
        include: [Include] = [],
        perPage: Int? = nil
    ) {
        self.courseID = courseID
        self.assignmentGroupID = assignmentGroupID
        self.orderBy = orderBy
        self.assignmentIDs = assignmentIDs
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        let context = Context(.course, id: courseID)
        if let assignmentGroupID = assignmentGroupID {
            return "\(context.pathComponent)/assignment_groups/\(assignmentGroupID)/assignments"
        }
        return "\(context.pathComponent)/assignments"
    }

    public var query: [APIQueryItem] {
        [
            .include(include.map { $0.rawValue }),
            .optionalValue("order_by", orderBy?.rawValue),
            .array("assignment_ids", assignmentIDs ?? []),
            .perPage(perPage),
        ]
    }
}
