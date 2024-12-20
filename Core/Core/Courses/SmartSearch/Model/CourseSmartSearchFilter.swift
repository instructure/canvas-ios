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

public struct CourseSmartSearchFilter: Equatable, SearchPreference {
    public enum SortMode: String, CaseIterable {
        case relevance
        case type
    }

    let sortMode: SortMode
    let includedTypes: [CourseSmartSearchResultType]

    init(sortMode: SortMode = .relevance, includedTypes: [CourseSmartSearchResultType]) {
        self.sortMode = sortMode
        self.includedTypes = includedTypes
    }

    func apply(to result: CourseSmartSearchResult) -> Bool {
        return includedTypes.contains(result.content_type)
    }

    public var isActive: Bool {
        return (1 ..< CourseSmartSearchResultType.allCases.count)
            .contains(includedTypes.count)
    }
}

extension CourseSmartSearchResultType {
    static var filterableTypes: [CourseSmartSearchResultType] {
        return [.assignment, .page, .announcement, .discussion]
    }
}
