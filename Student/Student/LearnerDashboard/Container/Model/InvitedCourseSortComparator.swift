//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Foundation

/// Sorts invited courses by enrollment creation date (oldest first) with fallback to course name.
///
/// This comparator implements a two-tier sorting strategy:
/// - Primary: Sorts by invitation creation date in ascending order (oldest first)
/// - Secondary: Sorts alphabetically by course name when dates are equal or missing
///
/// Courses with valid creation dates always appear before courses without dates.
struct InvitedCourseSortComparator: SortComparator {
    typealias Compared = Course
    var order: SortOrder = .forward

    /// Compares two courses based on their invited enrollment creation dates and course names.
    ///
    /// - Parameters:
    ///   - lhs: The first course to compare
    ///   - rhs: The second course to compare
    /// - Returns: A `ComparisonResult` indicating the ordering of the two courses
    func compare(_ lhs: Course, _ rhs: Course) -> ComparisonResult {
        let lhsEnrollment = lhs.enrollments?.first { $0.state == .invited && $0.id != nil }
        let rhsEnrollment = rhs.enrollments?.first { $0.state == .invited && $0.id != nil }

        let lhsDate = lhsEnrollment?.createdAt
        let rhsDate = rhsEnrollment?.createdAt

        switch (lhsDate, rhsDate) {
        case (.some(let date1), .some(let date2)):
            if date1 > date2 {
                return .orderedDescending
            } else if date1 < date2 {
                return .orderedAscending
            } else {
                return compareByName(lhs, rhs)
            }
        case (.some, .none):
            return .orderedAscending
        case (.none, .some):
            return .orderedDescending
        case (.none, .none):
            return compareByName(lhs, rhs)
        }
    }

    private func compareByName(_ lhs: Course, _ rhs: Course) -> ComparisonResult {
        let lhsName = lhs.name ?? ""
        let rhsName = rhs.name ?? ""
        return lhsName.localizedStandardCompare(rhsName)
    }
}
