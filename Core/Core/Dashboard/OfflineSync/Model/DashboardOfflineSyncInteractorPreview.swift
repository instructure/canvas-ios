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

#if DEBUG

import Combine

class DashboardOfflineSyncInteractorPreview: CourseSyncProgressObserverInteractor {
    private let env = PreviewEnvironment()
    private lazy var context = env.database.viewContext

    func observeDownloadProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never> {
        let bytesToDownload = 10_000_000
        let progressUpdates = stride(from: 0, to: bytesToDownload + 1, by: 1_000_000).map { $0 }
        return Publishers
            .Sequence<[Int], Never>(sequence: progressUpdates)
            .flatMap(maxPublishers: .max(1)) { Just($0).delay(for: 0.5, scheduler: RunLoop.main) }
            .map { [context] in
                let entity: CourseSyncDownloadProgress = context.insert()
                entity.bytesToDownload = bytesToDownload
                entity.bytesDownloaded = $0
                return entity
            }
            .map {
                ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State.data([$0])
            }
            .eraseToAnyPublisher()
    }

    func observeStateProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncStateProgressUseCase>.State, Never> {
        Just(.data([])).eraseToAnyPublisher()
    }
}

#endif
