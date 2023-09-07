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
import mobile_offline_downloader_ios

final class DownloadsCourseCategoryViewModel: Identifiable, Hashable {
    static func == (lhs: DownloadsCourseCategoryViewModel, rhs: DownloadsCourseCategoryViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: String = Foundation.UUID().uuidString
    var content: [OfflineDownloaderEntry]
    let contentType: ContentType
    let course: Course

    enum ContentType {
        case pages
        case modules
        case files
    }

    var courseColor: UIColor {
        UIColor(hexString: course.courseColor) ?? course.color
    }

    var title: String {
        switch contentType {
        case .pages:
            return "Pages"
        case .modules:
            return "Modules"
        case .files:
            return "Files"
        }
    }

    init(course: Course, content: [OfflineDownloaderEntry], contentType: ContentType) {
        self.contentType = contentType
        self.course = course
        self.content = content
    }
}
