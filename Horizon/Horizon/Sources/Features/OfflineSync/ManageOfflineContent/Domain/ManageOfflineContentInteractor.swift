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

import Core
import Combine

protocol ManageOfflineContentInteractor {
    func getCourses(ignoreCache: Bool) -> AnyPublisher<[OfflineCourseItem], Error>
}

final class ManageOfflineContentInteractorLive: ManageOfflineContentInteractor {
    // MARK: - Dependencies

    private let userID: String
    private let session: SessionDefaults

    // MARK: - Init

    init(userID: String, session: SessionDefaults) {
        self.userID = userID
        self.session = session
    }

    func getCourses(ignoreCache: Bool) -> AnyPublisher<[OfflineCourseItem], Error> {
        ReactiveStore(useCase: GetHCourseSelectionUseCase(userId: userID))
            .getEntities(ignoreCache: ignoreCache)
            .map { [session] courses in
                courses.map { OfflineCourseItem(from: $0, offlineSyncItems: session.offlineSyncSelections) }
            }
            .eraseToAnyPublisher()
    }
}
