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
    func observeCombinedFileProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncFileProgressUseCase>.State, Never>
    func observeEntryProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncEntryProgressUseCase>.State, Never>
}

final class CourseSyncProgressObserverInteractorLive: CourseSyncProgressObserverInteractor {
    private let context: NSManagedObjectContext
    private lazy var fileProgressUseCase = ReactiveStore(
        context: context,
        useCase: GetCourseSyncFileProgressUseCase(scope: .all)
    )
    private lazy var entryProgressUseCase = ReactiveStore(
        context: context,
        useCase: GetCourseSyncEntryProgressUseCase(
            scope: .all(
                orderBy: #keyPath(CourseSyncEntryProgress.id),
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

    func observeCombinedFileProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncFileProgressUseCase>.State, Never> {
        fileProgressUseCase
            .observeEntities()
            .eraseToAnyPublisher()
    }

    func observeEntryProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncEntryProgressUseCase>.State, Never> {
        entryProgressUseCase
            .observeEntities()
            .eraseToAnyPublisher()
    }
}
