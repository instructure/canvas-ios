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
import Core

final class AssignmentDueDateTextsProviderMock: AssignmentDueDateTextsProvider {

    var formattedDueDatesCallsCount: Int = 0
    var formattedDueDatesInput: Assignment?
    var formattedDueDatesResult: [String] = []

    public func formattedDueDates(for assignment: Assignment) -> [String] {
        formattedDueDatesCallsCount += 1
        formattedDueDatesInput = assignment
        return formattedDueDatesResult
    }

    // MARK: - dueDateItems

    var dueDateItemsCallsCount: Int = 0
    var dueDateItemsInput: Assignment?
    var dueDateItemsResult: [AssignmentDateListItem] = []

    func dueDateItems(for assignment: Assignment) -> [AssignmentDateListItem] {
        dueDateItemsCallsCount += 1
        dueDateItemsInput = assignment
        return dueDateItemsResult
    }
}
