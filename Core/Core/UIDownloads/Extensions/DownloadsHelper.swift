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

final class DownloadsHelper {

    static func filter(courseId: String, entries: [OfflineDownloaderEntry]) -> [OfflineDownloaderEntry] {
        entries.filter { $0.userInfo?.contains("courses/\(courseId)") == true }
    }

    static func pages(courseId: String, entries: [OfflineDownloaderEntry]) -> [OfflineDownloaderEntry] {
        entries
            .filter {
                $0.userInfo?.lowercased().contains("page:") == true
            }
    }

    static func moduleItems(courseId: String, entries: [OfflineDownloaderEntry]) -> [OfflineDownloaderEntry] {
        entries
            .filter {
                $0.userInfo?.lowercased().contains("moduleitem:") == true
            }
    }

    static func files(courseId: String, entries: [OfflineDownloaderEntry]) -> [OfflineDownloaderEntry] {
        entries
            .filter {
                $0.userInfo?.lowercased().contains("file:") == true
            }
    }

    static func getCourseId(userInfo: String) -> String? {
        if let url = URL(string: userInfo),
           let index = url.pathComponents.firstIndex(of: "courses"),
           url.pathComponents.indices.contains(index + 1) {
            return url.pathComponents[index + 1]
        }
        return nil
    }

    static func categories(
        from entries: [OfflineDownloaderEntry],
        courseDataModel: CourseStorageDataModel
    ) -> [DownloadsCourseCategoryViewModel] {
        var categories: [DownloadsCourseCategoryViewModel] = []

        let courseEntries = DownloadsHelper.filter(
            courseId: courseDataModel.course.id,
            entries: entries
        )
        let pagesSection = DownloadsHelper.pages(
            courseId: courseDataModel.course.id,
            entries: courseEntries
        )
        let modulesSection = DownloadsHelper.moduleItems(
            courseId: courseDataModel.course.id,
            entries: courseEntries
        )

        let filesSection = DownloadsHelper.files(
            courseId: courseDataModel.course.id,
            entries: courseEntries
        )

        if !pagesSection.isEmpty {
            categories.append(
                DownloadsCourseCategoryViewModel(
                    course: courseDataModel.course,
                    content: pagesSection,
                    contentType: .pages
                )
            )
        }
        if !modulesSection.isEmpty {
            categories.append(
                DownloadsCourseCategoryViewModel(
                    course: courseDataModel.course,
                    content: modulesSection,
                    contentType: .modules
                )
            )
        }
        if !filesSection.isEmpty {
            categories.append(
                DownloadsCourseCategoryViewModel(
                    course: courseDataModel.course,
                    content: filesSection,
                    contentType: .files
                )
            )
        }
        return categories
    }
}
