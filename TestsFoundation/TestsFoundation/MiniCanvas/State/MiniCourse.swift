//
// This file is part of Canvas.
// Copyright (C) $YEAR-present  Instructure, Inc.
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
@testable import Core

public class MiniCourse: Encodable {
    public var api: APICourse
    private(set) public var assignments: [MiniAssignment] = []
    public var assignmentGroups: [APIAssignmentGroup] = []
    public var tabs: [APITab]
    public var externalTools: [APIExternalTool] = []
    public var gradingPeriods: [APIGradingPeriod] = []
    public var featureFlags: [String] = []

    public var id: String { api.id.value }

    public func assignment(byId id: String?) -> MiniAssignment? {
        assignments.first { $0.id == id }
    }

    public func add(assignment: MiniAssignment, toGroupAtIndex index: Int) {
        assignments.append(assignment)
        if assignmentGroups[index].assignments == nil {
            assignmentGroups[index].assignments = []
        }
        assignmentGroups[index].assignments!.append(assignment.api)
    }

    init(_ course: APICourse) {
        self.api = course
        tabs = [
            "announcements", "assignments", "discussions", "files",
            "grades", "modules", "pages", "people", "quizzes",
        ].map { tabName in
            APITab.make(
                id: ID(tabName),
                html_url: URL(string: "/courses/\(course.id)/\(tabName)")!,
                label: "\(tabName.capitalized)"
            )
        }
    }
}
