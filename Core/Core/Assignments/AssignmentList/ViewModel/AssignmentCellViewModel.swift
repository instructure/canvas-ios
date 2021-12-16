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

import Foundation

public class AssignmentCellViewModel: ObservableObject {
    public private (set) var assignment: Assignment
    private var isTeacher: Bool = true

    public init(assignment: Assignment) {
        self.assignment = assignment
    }

    public var route: URL? {
        if let discussionTopicID = assignment.discussionTopic?.id, isTeacher {
            return URL(string: "/courses/\(assignment.courseID)/discussion_topics/\(discussionTopicID)")
        } else {
            return assignment.htmlURL
        }
    }

    public var icon: UIImage {
        let icon = assignment.icon ?? .assignmentLine
        if isTeacher {
            icon
        }
    }

    public var name: String {
        assignment.name
    }

    public var dueText: String {
        assignment.dueText
    }
}

