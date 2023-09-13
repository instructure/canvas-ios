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

enum OfflineSyncWaitToFinishInteractor {

    /**
     - returns: A publisher that publishes a value then finishes when the first `CourseSyncDownloadProgress`'s
     `isFinished` property changes to `true` in the database.
     */
    static func wait() -> AnyPublisher<Void, Never> {
        let downloadFinishedPredicate = NSPredicate(key: #keyPath(CourseSyncDownloadProgress.isFinished), equals: true)
        let downloadFinishedScope = Scope(predicate: downloadFinishedPredicate, order: [])
        let useCase = LocalUseCase<CourseSyncDownloadProgress>(scope: downloadFinishedScope)
        let store = ReactiveStore(offlineModeInteractor: nil, useCase: useCase)

        return store
            .observeEntities()
            .compactMap { $0.firstItem }
            .mapToVoid()
            .first()
            .map { store.cancel() }
            .eraseToAnyPublisher()
    }
}
