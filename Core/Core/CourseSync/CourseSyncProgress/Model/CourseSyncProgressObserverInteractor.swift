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
import CoreData
import Foundation

protocol CourseSyncProgressObserverInteractor {
    func observeDownloadProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never>
    func observeStateProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncStateProgressUseCase>.State, Never>
}

final class CourseSyncProgressObserverInteractorLive: CourseSyncProgressObserverInteractor {
    private let context: NSManagedObjectContext
    private lazy var fileProgressUseCase = ReactiveStore(
        context: context,
        useCase: GetCourseSyncDownloadProgressUseCase(scope: .all)
    )
    private lazy var entryProgressUseCase = ReactiveStore(
        context: context,
        useCase: GetCourseSyncStateProgressUseCase(
            scope: .all(
                orderBy: #keyPath(CourseSyncStateProgress.id),
                ascending: true
            )
        )
    )

    public init(container: NSPersistentContainer = AppEnvironment.shared.database) {
        context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
    }

    deinit {
        fileProgressUseCase.cancel()
        entryProgressUseCase.cancel()
    }

    func observeDownloadProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never> {
        fileProgressUseCase
            .observeEntities()
            .eraseToAnyPublisher()
    }

    func observeStateProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncStateProgressUseCase>.State, Never> {
        entryProgressUseCase
            .observeEntities()
            .eraseToAnyPublisher()
    }
}
