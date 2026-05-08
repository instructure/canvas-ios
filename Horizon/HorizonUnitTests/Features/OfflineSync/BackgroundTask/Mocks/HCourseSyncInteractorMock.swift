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
import Core
@testable import Horizon

final class HCourseSyncInteractorMock: HCourseSyncInteractor {
    var progressSubject = PassthroughSubject<HOfflineSyncProgress, Never>()
    var progressPublisher: AnyPublisher<HOfflineSyncProgress, Never> {
        progressSubject.eraseToAnyPublisher()
    }

    var downloadItemsSubject = PassthroughSubject<[OfflineCourseItem], Never>()
    var downloadItems: AnyPublisher<[OfflineCourseItem], Never> {
        downloadItemsSubject.eraseToAnyPublisher()
    }

    var errorSubject = PassthroughSubject<Void, Never>()
    var errorPublisher: AnyPublisher<Void, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    var downloadContentCallCount = 0
    var lastDownloadedCourses: [OfflineCourseItem] = []

    var cancelSyncCallCount = 0
    var clearCallCount = 0

    func downloadContent(courses: [OfflineCourseItem], environment: AppEnvironment) {
        downloadContentCallCount += 1
        lastDownloadedCourses = courses
    }

    func cancelSync() {
        cancelSyncCallCount += 1
    }

    func clear() {
        clearCallCount += 1
    }
}
