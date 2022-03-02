//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct AssignmentPickerListResponse: Codable, Equatable {
    public struct Assignment: Codable, Equatable {
        struct LockInfo: Codable, Equatable {
            let isLocked: Bool
        }

        let name: String
        let _id: String
        let submissionTypes: [SubmissionType]
        let lockInfo: LockInfo

        public var isLocked: Bool { lockInfo.isLocked }
    }

    struct Data: Codable, Equatable {
        struct Course: Codable, Equatable {
            struct AssignmentsConnection: Codable, Equatable {
                let nodes: [Assignment]
            }
            let assignmentsConnection: AssignmentsConnection
        }
        let course: Course
    }

    public var assignments: [Assignment] { data.course.assignmentsConnection.nodes.map { $0 } }

    let data: Self.Data
}
