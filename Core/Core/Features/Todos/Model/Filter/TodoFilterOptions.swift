//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct TodoFilterOptions: Codable, Equatable {
    public static let `default` = TodoFilterOptions(
        visibilityOptions: [],
        dateRangeStart: .lastWeek,
        dateRangeEnd: .nextWeek
    )

    public let visibilityOptions: Set<TodoVisibilityOption>
    public let dateRangeStart: TodoDateRangeStart
    public let dateRangeEnd: TodoDateRangeEnd

    public var startDate: Date {
        dateRangeStart.startDate()
    }

    public var endDate: Date {
        dateRangeEnd.endDate()
    }

    public var isDefault: Bool {
        self == Self.default
    }

    public init(
        visibilityOptions: Set<TodoVisibilityOption>,
        dateRangeStart: TodoDateRangeStart,
        dateRangeEnd: TodoDateRangeEnd
    ) {
        self.visibilityOptions = visibilityOptions
        self.dateRangeStart = dateRangeStart
        self.dateRangeEnd = dateRangeEnd
    }

    public func shouldInclude(plannable: Plannable, course: Course?) -> Bool {
        guard let plannableDate = plannable.date else { return false }

        let isWithinDateRange = plannableDate >= startDate && plannableDate <= endDate
        guard isWithinDateRange else { return false }

        let typeMatches = visibilityOptions.shouldInclude(plannableType: plannable.plannableType)
        guard typeMatches else { return false }

        let completionMatches = visibilityOptions.shouldInclude(
            isCompleted: plannable.isMarkedComplete,
            isSubmitted: plannable.isSubmitted
        )
        guard completionMatches else { return false }

        let favoriteMatches = visibilityOptions.shouldInclude(
            isFavorite: course?.isFavorite,
            hasNoCourse: course == nil
        )
        guard favoriteMatches else { return false }

        return true
    }
}
