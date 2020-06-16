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
    let id: ID
    let course_id: ID
    let quiz_id: ID?
    let name: String
    let description: String?
    let points_possible: Double?
    let due_at: Date?
    let html_url: URL
    let grade_group_students_individually: Bool?
    let grading_type: GradingType
    let submission_types: [SubmissionType]
    let allowed_extensions: [String]?
    let position: Int
    let unlock_at: Date?
    let lock_at: Date?
    let locked_for_user: Bool?
    let lock_explanation: String?
    let url: URL?
    let discussion_topic: APIDiscussionTopic?
    let rubric: [APIRubric]?
    var submission: APIList<APISubmission>?
    let use_rubric_for_grading: Bool?
    let rubric_settings: APIRubricSettings?
    let assignment_group_id: ID?
    let all_dates: [APIAssignmentDate]?
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

public enum GradingType: String, Codable {
    case pass_fail, percent, letter_grade, gpa_scale, points, not_graded
}

#if DEBUG
extension APIAssignment {
    public static func make(
        id: ID = "1",
        course_id: ID = "1",
        quiz_id: ID? = nil,
        name: String = "some assignment",
        description: String? = "<p>Do the following:</p>...",
        points_possible: Double? = 10,
        due_at: Date? = nil,
        html_url: URL? = nil,
        submission: APISubmission? = .make(submitted_at: nil, workflow_state: .unsubmitted),
        submissions: [APISubmission]? = nil,
        grade_group_students_individually: Bool? = nil,
        grading_type: GradingType = .points,
        submission_types: [SubmissionType] = [.online_text_entry],
        allowed_extensions: [String]? = nil,
        position: Int = 0,
        unlock_at: Date? = nil,
        lock_at: Date? = nil,
        locked_for_user: Bool? = false,
        lock_explanation: String? = nil,
        url: URL? = nil,
        discussion_topic: APIDiscussionTopic? = nil,
        rubric: [APIRubric]? = nil,
        use_rubric_for_grading: Bool? = nil,
        rubric_settings: APIRubricSettings? = nil,
        assignment_group_id: ID? = nil,
        all_dates: [APIAssignmentDate]? = nil
    ) -> APIAssignment {

        var submissionList: APIList<APISubmission>?
        if let submissions = submissions, submissions.count > 0 {
            submissionList = APIList<APISubmission>(values: submissions)
        } else if let submission = submission {
            submissionList = APIList<APISubmission>( submission )
        }

        return APIAssignment(
            id: id,
            course_id: course_id,
            quiz_id: quiz_id,
            name: name,
            description: description,
            points_possible: points_possible,
            due_at: due_at,
            html_url: html_url ?? URL(string: "https://canvas.instructure.com/courses/\(course_id)/assignments/\(id)")!,
            grade_group_students_individually: grade_group_students_individually,
            grading_type: grading_type,
            submission_types: submission_types,
            allowed_extensions: allowed_extensions,
            position: position,
            unlock_at: unlock_at,
            lock_at: lock_at,
            locked_for_user: locked_for_user,
            lock_explanation: lock_explanation,
            url: url,
            discussion_topic: discussion_topic,
            rubric: rubric,
            submission: submissionList,
            use_rubric_for_grading: use_rubric_for_grading,
            rubric_settings: rubric_settings,
            assignment_group_id: assignment_group_id,
            all_dates: all_dates
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

    public enum GetAssignmentInclude: String {
        case submission, overrides
    }

    public var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        var include = self.include.map { $0.rawValue }
        include.append("observed_users")
        query.append(.array("include", include))
        if AppEnvironment.shared.app == .teacher || allDates == true {
            query.append(.value("all_dates", "true"))
        }
        return query
    }
}

struct APIAssignmentParameters: Codable, Equatable {
    let name: String
    let description: String?
    let points_possible: Double
    let due_at: Date?
    let submission_types: [SubmissionType]
    let allowed_extensions: [String]
    let published: Bool
    let grading_type: GradingType
    let lock_at: Date?
    let unlock_at: Date?
}

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.create
struct PostAssignmentRequest: APIRequestable {
    typealias Response = APIAssignment
    struct Body: Codable, Equatable {
        let assignment: APIAssignmentParameters
    }

    let courseID: String

    let body: Body?
    let method = APIMethod.post
    public var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/assignments"
    }
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
