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

public protocol AssignmentDateTextsProvider {

    /// If `assignment` has sub-assignments, this returns the formatted due date for each sub-assignment,
    /// or only a single item if any of the dates is a special case which overrules them.
    /// If `assignment` has no sub-assignments, this returns the formatted due date.
    /// This method formats dates adding the "Due" prefix.
    func summarizedDueDates(for assignment: Assignment) -> [String]

    /// Returns items which contain a title & formatted due date pair.
    /// If `assignment` has sub-assignments, this returns an item for each sub-assignment.
    /// In this case each title is the sub-assignments title and the "due" suffix.
    /// If `assignment` has no sub-assignments, this returns a single item with the title "Due".
    /// If `assignment` or it's sub-assignments have overrides, the returned item's title is `nil`.
    /// This method formats dates without adding the "Due" prefix.
    func dueDateItems(for assignment: Assignment) -> [AssignmentDateListItem]
}

extension AssignmentDateTextsProvider where Self == AssignmentDateTextsProviderLive {
    public static var live: AssignmentDateTextsProviderLive { .init() }
}

public struct AssignmentDateTextsProviderLive: AssignmentDateTextsProvider {

    public init() {}

    public func summarizedDueDates(for assignment: Assignment) -> [String] {
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

public struct AssignmentDateListItem: Equatable {
    public let title: String?
    public let date: String
}
