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
import Combine
import mobile_offline_downloader_ios

final class DownloadsCourseDetailViewModel: ObservableObject {

    // MARK: - Injections -

    private var storageManager: OfflineStorageManager = .shared
    private var downloadsManager: OfflineDownloadsManager = .shared

    // MARK: - Properties -

    enum State {
        case none // init
        case loading
        case loaded
        case updated
    }

    @Published var state: State = .loaded

    // MARK: - Content -

    let courseViewModel: DownloadCourseViewModel
    var categories: [DownloadsCourseCategoryViewModel]
    var onDeletedAll: (() -> Void)?

    var title: String {
        courseViewModel.courseCode
    }

    // MARK: - Lifecycle -

    init(
        courseViewModel: DownloadCourseViewModel,
        categories: [DownloadsCourseCategoryViewModel],
        onDeletedAll: (() -> Void)? = nil
    ) {
        self.courseViewModel = courseViewModel
        self.categories = categories
        self.onDeletedAll = onDeletedAll
    }

    func delete(entry: OfflineDownloaderEntry, from sectionViewModel: DownloadsCourseCategoryViewModel) {
        guard let index = categories.firstIndex(where: {$0.id == sectionViewModel.id}),
            let indexContent = categories[index].content.firstIndex(
            where: {$0.dataModel.id == entry.dataModel.id}
        ) else {
            return
        }

        categories[index].content.remove(at: indexContent)

        if categories[index].content.isEmpty {
            categories.remove(at: index)
        }

        if categories.isEmpty {
            onDeletedAll?()
        }

        state = .updated
    }

    func delete(sectionViewModel: DownloadsCourseCategoryViewModel) {
        guard let index = categories.firstIndex(where: {$0.id == sectionViewModel.id}) else {
            return
        }
        categories.remove(at: index)

        if categories.isEmpty {
            onDeletedAll?()
        }

        state = .updated
    }
}
