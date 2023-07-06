//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public enum CourseEntrySelection: Codable, Equatable, Comparable, Hashable {
    public typealias EntryID = String
    public typealias TabID = String
    public typealias FileID = String

    case course(EntryID)
    case tab(EntryID, TabID)
    case file(EntryID, FileID)

    private var sortPriority: Int {
        switch self {
        case .course: return 0
        case .tab: return 1
        case .file: return 2
        }
    }

    public static func < (lhs: CourseEntrySelection, rhs: CourseEntrySelection) -> Bool {
        switch (lhs, rhs) {
        case let (.course(lhsEntryID), .course(rhsEntryID)):
            return lhsEntryID <= rhsEntryID
        case (let .file(lhsCourseID, lhsFileID), let .file(rhsCourseID, rhsFileID)):
            return lhsCourseID <= rhsCourseID && lhsFileID <= rhsFileID
        case (let .tab(lhsCourseID, lhsTabID), let .tab(rhsCourseID, rhsTabID)):
            return lhsCourseID <= rhsCourseID && lhsTabID <= rhsTabID
        default:
            return lhs.sortPriority < rhs.sortPriority
        }
    }
}
