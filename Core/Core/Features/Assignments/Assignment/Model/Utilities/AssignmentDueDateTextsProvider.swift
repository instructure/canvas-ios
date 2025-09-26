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

public protocol AssignmentDueDateTextsProvider {

    /// Return an array of formatted due dates, or only a single item
    /// if any of the dates is a special case which overrules them.
    func formattedDueDates(for assignment: Assignment) -> [String]

    func dueDateItems(for assignment: Assignment) -> [AssignmentDateListItem]
}

extension AssignmentDueDateTextsProvider where Self == AssignmentDueDateTextsProviderLive {
    public static var live: AssignmentDueDateTextsProviderLive { .init() }
}

public struct AssignmentDateListItem: Equatable {
    public let title: String?
    public let date: String
}

public struct AssignmentDueDateTextsProviderLive: AssignmentDueDateTextsProvider {

    public init() {}

    public func formattedDueDates(for assignment: Assignment) -> [String] {
        let isTeacher = AppEnvironment.shared.app == .teacher

        if assignment.hasSubAssignments {
            return assignment.checkpoints
                .map {
                    DueDateSummary(
                        $0.dueDate,
                        lockDate: $0.lockDate,
                        hasOverrides: isTeacher && $0.overrides.isNotEmpty
                    )
                }
                .reduceIfNeeded()
                .map(\.text)
        } else {
            return [
                DueDateFormatter.format(
                    assignment.dueAt,
                    lockDate: assignment.lockAt,
                    hasOverrides: isTeacher && assignment.hasOverrides
                )
            ]
        }
    }

    public func dueDateItems(for assignment: Assignment) -> [AssignmentDateListItem] {
        if hasOverrides(assignment: assignment) {
            return [.init(title: nil, date: DueDateFormatter.multipleDueDatesText)]
        }

        if assignment.hasSubAssignments {
            return assignment.checkpoints.map {
                let title = String(localized: "\($0.title) due", bundle: .core, comment: "Header before a due date. Example: 'Some task due'")
                let date = DueDateFormatter.formatWithoutPrefix($0.dueDate)
                return .init(title: title, date: date)
            }
        } else {
            let title = String(localized: "Due", bundle: .core)
            let date = DueDateFormatter.formatWithoutPrefix(assignment.dueAt)
            return [.init(title: title, date: date)]
        }
    }

    private func hasOverrides(assignment: Assignment) -> Bool {
        guard AppEnvironment.shared.app == .teacher else { return false }

        if assignment.hasSubAssignments {
            return assignment.checkpoints.contains {
                $0.overrides.isNotEmpty
            }
        } else {
            return assignment.hasOverrides
        }
    }
}
