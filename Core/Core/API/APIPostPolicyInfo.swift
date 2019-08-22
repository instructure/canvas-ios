//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public struct APIPostPolicyInfo: Codable {
    public var sections: [SectionNode]
    public var submissions: [SubmissionNode]

    public init(sections: [SectionNode], submissions: [SubmissionNode]) {
        self.sections = sections
        self.submissions = submissions
    }

    public init(from decoder: Decoder) throws {
        let rawResponse = try APIPostPolicyInfoRawServerResponse(from: decoder)
        sections = rawResponse.data.course.sections.nodes
        submissions = rawResponse.data.assignment.submissions.nodes
    }

    public func encode(to encoder: Encoder) throws {
    }

    public struct SectionNode: Decodable {
        public var id: String
        public var name: String
    }

    public struct SubmissionNode: Decodable {
        public var score: Double?
        public var excused: Bool
        public var state: String
        public var postedAt: Date?
        public var isGraded: Bool {
            return ( score != nil && state == "graded" ) || excused
        }

        public var isHidden: Bool {
            return isGraded && postedAt == nil
        }
    }
}

private struct APIPostPolicyInfoRawServerResponse: Decodable {
    struct Sections: Decodable {
        var nodes: [APIPostPolicyInfo.SectionNode]
    }

    struct PostPolicyData: Decodable {
        var course: Course
        var assignment: Assignment
    }

    struct Course: Decodable {
        var sections: Sections
    }

    struct Assignment: Decodable {
        var submissions: Submissions
    }

    struct Submissions: Decodable {
        var nodes: [APIPostPolicyInfo.SubmissionNode]
    }

    var data: PostPolicyData
}
