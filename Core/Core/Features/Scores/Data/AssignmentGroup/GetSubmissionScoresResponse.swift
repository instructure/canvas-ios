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

public struct GetSubmissionScoresResponse: Codable {
    let data: DataClass?

    // MARK: - DataClass
    struct DataClass: Codable {
        let legacyNode: LegacyNode?
    }

    // MARK: - LegacyNode
    struct LegacyNode: Codable {
        let id: String?
        let grades: Grades?
        let course: Course?
    }

    // MARK: - Course
    struct Course: Codable {
        let applyGroupWeights: Bool?
        let assignmentGroups: [AssignmentGroup]?
    }

    public struct AssignmentGroup: Codable {
        let id, name: String?
        let groupWeight: Double?
        let gradesConnection: GradesConnection?
        let assignmentsConnection: AssignmentsConnection?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, groupWeight, gradesConnection, assignmentsConnection
        }
    }

    // MARK: - AssignmentsConnection
    struct AssignmentsConnection: Codable {
        let nodes: [Assignment]?
    }

    public struct Assignment: Codable {
        let id, name: String?
        let pointsPossible: Double?
        let htmlUrl: URL?
        let dueAt: Date?
        let submissionsConnection: SubmissionNode?
        let submissionTypes: [String]?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, pointsPossible, dueAt, submissionsConnection, submissionTypes, htmlUrl
        }
    }

    struct SubmissionNode: Codable {
        let nodes: [Submission]?
    }

    struct Submission: Codable {
        let state: String?
        let late, excused, missing: Bool?
        let submittedAt: Date?
        let score: Double?
        let grade: String?
        let submissionStatus: String?
        let commentsConnection: Comment?
    }

    // MARK: - CommentsConnection
    struct Comment: Codable {
        let nodes: [CommentsConnectionNode]?
    }

    // MARK: - CommentsConnectionNode
    struct CommentsConnectionNode: Codable {
        let id: String?
        let read: Bool?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case read
        }
    }

    struct GradesConnection: Codable {
        let nodes: [GradesConnectionNode]?
    }

    struct GradesConnectionNode: Codable {
        let currentScore, finalScore: Double?
        let state: String?
    }

    struct Grades: Codable {
        let finalScore: Double?
        let finalGrade: String?
    }
}
