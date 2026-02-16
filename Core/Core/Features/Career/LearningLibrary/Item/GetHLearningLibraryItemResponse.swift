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

import Foundation

public struct GetHLearningLibraryItemResponse: Codable, PagedResponse {
    public var page: [LearningLibraryItemsResponse] { data?.learningLibraryCollectionItems?.items ?? [] }
    public typealias Page = [LearningLibraryItemsResponse]
    public let data: DataContainer?

    public struct DataContainer: Codable {
        let learningLibraryCollectionItems: LearningLibraryCollectionItems?
    }

    public struct LearningLibraryCollectionItems: Codable {
        let items: [LearningLibraryItemsResponse]?
        let pageInfo: PageInfo?
    }
    struct PageInfo: Codable {
        let nextCursor: String?
        let previousCursor: String?
        let hasNextPage: Bool
        let hasPreviousPage: Bool
    }
}
