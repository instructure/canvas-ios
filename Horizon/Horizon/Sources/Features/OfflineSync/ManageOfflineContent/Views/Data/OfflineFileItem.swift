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

struct OfflineFileItem: Identifiable {
    let id: String
    let name: String
    let size: String
    let url: URL?
    let mimeClass: String
    let courseID: String
    let sizeInBytes: Double
    let updatedAt: Date?
    var isSelected: Bool = false
    var downloadState: OfflineDownloadState = .idle
    init(
        id: String,
        name: String,
        size: String,
        url: URL? = nil,
        sizeInBytes: Double,
        isSelected: Bool,
        mimeClass: String,
        courseID: String,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.size = size
        self.url = url
        self.sizeInBytes = sizeInBytes
        self.isSelected = isSelected
        self.mimeClass = mimeClass
        self.courseID = courseID
        self.updatedAt = updatedAt
    }

    init(from entity: CDHCourseSelectionFile) {
        self.id = entity.id
        self.name = entity.name
        self.size = entity.size
        self.url = entity.url
        self.sizeInBytes = entity.sizeInBytes
        self.mimeClass = entity.mimeClass
        self.courseID = entity.courseID
        self.updatedAt = entity.updatedAt
    }
}
enum OfflineDownloadState: Equatable {
    case idle
    case loading
    case downloading(progress: Float)
    case downloaded
    case failed(String) // better than Error for Equatable
}
