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

import Combine
import CombineExt
import Foundation

struct SyncProgress {
    let total: Int64
    let progress: Int64
}

protocol CourseSyncProgressInteractor {
    func getSyncProgress() -> SyncProgress
    func getCourseSyncProgressEntries() -> AnyPublisher<[CourseSyncProgressEntry], Error>
    func setProgress(selection: CourseEntrySelection, progress: Float?)
    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool)
    func remove(selection: CourseEntrySelection)
}

final class CourseSyncProgressInteractorLive: CourseSyncProgressInteractor {

    // MARK: - Progress info view

    func getSyncProgress() -> SyncProgress {
        let total = getTotalSize()
        let progress = getProgressSize()
        return SyncProgress(total: total, progress: progress)
    }

    private func getTotalSize() -> Int64 {
        // TODO: logic
        return 1
    }

    private func getProgressSize() -> Int64 {
        // TODO: logic
        return 1
    }

    // MARK: - Progress item view

    func getCourseSyncProgressEntries() -> AnyPublisher<[CourseSyncProgressEntry], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func setProgress(selection: CourseEntrySelection, progress: Float?) {
    }

    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool) {
    }

    func remove(selection: CourseEntrySelection) {
    }
}
