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

public class AssignmentDateSectionViewModel: DateSectionViewModel {


    @ObservedObject var assignment: Assignment
    public var firstAssignmentDate: AssignmentDate?

    public init(assignment: Assignment) {
        self.assignment = assignment
        firstAssignmentDate = assignment.allDates.first
    }

    public var hasMultipleDueDates: Bool {
        assignment.allDates.count > 1
    }

    public var dueAt: Date? {
        assignment.dueAt ?? firstAssignmentDate?.dueAt
    }

    public var lockAt: Date? {
        firstAssignmentDate?.lockAt ?? assignment.lockAt
    }

    public var unlockAt: Date? {
        firstAssignmentDate?.unlockAt ?? assignment.unlockAt
    }

    public func buttonTapped(router: Router, viewController: WeakViewController) {
        router.route(to: "courses/\(assignment.courseID)/assignments/\(assignment.id)/due_dates", from: viewController)
    }
}
