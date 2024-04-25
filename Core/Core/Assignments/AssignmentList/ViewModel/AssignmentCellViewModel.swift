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

import SwiftUI

public class AssignmentCellViewModel: ObservableObject {
    public let assignment: Assignment
    public let courseColor: UIColor?

    private let env = AppEnvironment.shared

    public init(assignment: Assignment, courseColor: UIColor?) {
        self.assignment = assignment
        self.courseColor = courseColor
    }

    public var route: URL? {
        if let discussionTopicID = assignment.discussionTopic?.id, isTeacher {
            if isDiscussionRedesignEnabled() {
                return assignment.htmlURL
            } else {
                return URL(string: "/courses/\(assignment.courseID)/discussion_topics/\(discussionTopicID)")
            }
        } else {
            return assignment.htmlURL
        }
    }

    public var icon: UIImage {
        assignment.icon ?? .assignmentLine
    }

    public var name: String {
        assignment.name
    }

    public var published: Bool? {
        guard isTeacher else { return nil }
        return assignment.published
    }

    public var needsGradingText: String? {
        guard assignment.needsGradingCount > 0, assignment.gradingType != .not_graded else {
            return nil
        }

        let format = String(localized: "d_needs_grading", bundle: .core)
        return String.localizedStringWithFormat(format, assignment.needsGradingCount).localizedUppercase
    }

    public var formattedDueDate: String {
        if let lockAt = assignment.lockAt, Clock.now > lockAt {
            return String(localized: "Availability: Closed", bundle: .core)
        }

        if assignment.hasMultipleDueDates {
            return String(localized: "Multiple Due Dates", bundle: .core)
        }

        if let dueAt = assignment.dueAt {
            let format = String(localized: "Due %@", bundle: .core, comment: "i.e. Due <Jan 10, 2020 at 9:00 PM>")
            return String.localizedStringWithFormat(format, dueAt.relativeDateTimeString)
        }

        return String(localized: "No Due Date", bundle: .core)
    }

    private var isTeacher: Bool {
        env.app == .teacher
    }

    private func isDiscussionRedesignEnabled() -> Bool {
        if let url = assignment.discussionTopic?.htmlURL, let context = Context(path: url.path) {
            return EmbeddedWebPageViewModelLive.isRedesignEnabled(in: context)
        } else {
            return false
        }
    }
}
