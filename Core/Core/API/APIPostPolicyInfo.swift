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
    public var sections: [SectionNode] {
        return data.course.sections.nodes
    }
    public var submissions: [SubmissionNode] {
        return data.assignment.submissions.nodes
    }
    internal var data: PostPolicyData

    public struct SectionNode: Codable, Equatable {
        public let id: String
        public let name: String
    }

    public struct SubmissionNode: Codable, Equatable, PostPolicyLogicProtocol {
        public let score: Double?
        public let excused: Bool
        public let state: String
        public let postedAt: Date?
        public var isGraded: Bool {
            return ( score != nil && state == "graded" ) || excused
        }

        public var isHidden: Bool {
            return isGraded && postedAt == nil
        }

        public var isPosted: Bool {
            return postedAt != nil && isGraded
        }
    }

    struct Sections: Codable {
        var nodes: [APIPostPolicyInfo.SectionNode]
    }

    struct PostPolicyData: Codable {
        var course: Course
        var assignment: Assignment
    }

    struct Course: Codable {
        var sections: Sections
    }

    struct Assignment: Codable {
        var submissions: Submissions
    }

    struct Submissions: Codable {
        var nodes: [APIPostPolicyInfo.SubmissionNode]
    }
}

public protocol PostPolicyLogicProtocol {
    var isGraded: Bool { get }
    var isHidden: Bool { get }
    var isPosted: Bool { get }
}

extension Array where Element: PostPolicyLogicProtocol {
    public var hiddenCount: Int {
        return filter { $0.isHidden }.count
    }

    public var postedCount: Int {
        return filter { $0.isPosted }.count
    }
}
