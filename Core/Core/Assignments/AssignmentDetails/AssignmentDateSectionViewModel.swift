//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class AssignmentDateSectionViewModel: DateSectionViewModelProtocol {

    public let isButton = true
    private var allDatesDate: AssignmentDate?
    @ObservedObject private var assignment: Assignment

    public init(assignment: Assignment) {
        self.assignment = assignment
        allDatesDate = assignment.allDates.first
    }

    public var hasMultipleDueDates: Bool {
        assignment.hasMultipleDueDates
    }

    public var dueAt: Date? {
        assignment.dueAt ?? allDatesDate?.dueAt
    }

    public var lockAt: Date? {
        allDatesDate?.lockAt ?? assignment.lockAt
    }

    public var unlockAt: Date? {
        allDatesDate?.unlockAt ?? assignment.unlockAt
    }

    public var forText: String {
        if allDatesDate?.base == true {
            return String(localized: "Everyone", bundle: .core)
        } else {
            return allDatesDate?.title ?? "-"
        }
    }

    public func buttonTapped(router: Router, viewController: WeakViewController) {
        router.route(to: "courses/\(assignment.courseID)/assignments/\(assignment.id)/due_dates", from: viewController)
    }
}
