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
import HorizonUI
import Foundation
import SwiftUI

struct LearningLibrarySectionModel: Identifiable, Equatable, PaginatedDataSourceSearchable {
    let id: String
    let name: String
    let hasMoreItems: Bool
    var items: [LearningLibraryCardModel]

    init(
        id: String,
        name: String,
        hasMoreItems: Bool = false,
        items: [LearningLibraryCardModel]
    ) {
        self.id = id
        self.name = name
        self.hasMoreItems = hasMoreItems
        self.items = items
    }

    init(
        for entity: CDHLearningLibraryCollection,
        hasMoreItems: Bool,
        items: [CDHLearningLibraryCollectionItem]
    ) {
        self.id = entity.id
        self.name = entity.name
        self.hasMoreItems = hasMoreItems
        self.items = items.map { .init(for: $0) }
    }

    var sortedItems: [LearningLibraryCardModel] {
        items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
//        items.sorted { $0.isRecommended && !$1.isRecommended }
    }

   mutating func update(item: LearningLibraryCardModel) {
        if let index = items.firstIndex(of: item) {
            items[index].update(with: item)
        }
    }
}
