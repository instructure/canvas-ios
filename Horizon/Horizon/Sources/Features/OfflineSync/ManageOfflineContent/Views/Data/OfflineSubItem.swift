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

struct OfflineSubItem: Identifiable {
    let id: String
    let name: String
    let size: String
    let url: URL?
    let mimeClass: String
    let sizeInBytes: Double
    var isSelected: Bool = false

    init(
        id: String,
        name: String,
        size: String,
        url: URL? = nil,
        sizeInBytes: Double,
        isSelected: Bool,
        mimeClass: String
    ) {
        self.id = id
        self.name = name
        self.size = size
        self.url = url
        self.sizeInBytes = sizeInBytes
        self.isSelected = isSelected
        self.mimeClass = mimeClass
    }

    init(from entity: CDHCourseSelectionFile) {
        self.id = entity.id
        self.name = entity.name
        self.size = entity.size
        self.url = entity.url
        self.sizeInBytes = entity.sizeInBytes
        self.mimeClass = entity.mimeClass
    }
}
