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

import Combine
import CombineSchedulers
import Core
import Observation
import Foundation

@Observable
final class HOfflineDownloadStatusViewModel {
    // MARK: - Outputs

    private(set) var syncProgress: Double = 0
    private(set) var syncDownloadedSize: String = ""
    private(set) var syncTotalSize: String = ""
    private(set) var isError = false

    // MARK: - Private variables

    private(set) var courses: [OfflineCourseItem] = []
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let syncInteractor: HCourseSyncInteractor

    // MARK: - Init

    init(
        syncInteractor: HCourseSyncInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.syncInteractor = syncInteractor

        syncInteractor.downloadItems
            .receive(on: scheduler)
            .sink { [weak self] items in
                guard let self else { return }
                courses = items
            }
            .store(in: &subscriptions)

        syncInteractor.progressPublisher
            .receive(on: scheduler)
            .sink { [weak self] progress in
                guard let self else { return }
                syncProgress = progress.progress
                syncDownloadedSize = progress.downloadedSize
                syncTotalSize = progress.totalSize
            }
            .store(in: &subscriptions)

        syncInteractor.errorPublisher
            .receive(on: scheduler)
            .sink { [weak self] in
                self?.isError = true
            }
            .store(in: &subscriptions)
    }

    func cancelSync() {
        syncInteractor.cancelSync()
    }

    func retrySync() {
        isError = false
        syncInteractor.downloadContent(courses: courses, environment: .shared)
    }
}
