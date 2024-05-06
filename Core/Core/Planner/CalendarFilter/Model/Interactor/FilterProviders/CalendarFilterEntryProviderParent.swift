//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct CalendarFilterEntryProviderParent: CalendarFilterEntryProvider {
    private let userName: String?
    private let userId: String?
    private let observedUserId: String?

    init(
        userName: String? = AppEnvironment.shared.currentSession?.userName,
        userId: String? = AppEnvironment.shared.currentSession?.userID,
        observedUserId: String?
    ) {
        self.userName = userName
        self.userId = userId
        self.observedUserId = observedUserId
    }

    func make(ignoreCache: Bool) -> AnyPublisher<[CDCalendarFilterEntry], Error>? {
        guard let userName, let userId, let observedUserId else {
            return nil
        }

        let useCase = GetParentCalendarFilters(
            currentUserName: userName,
            currentUserId: userId,
            observedStudentId: observedUserId
        )
        return ReactiveStore(useCase: useCase).getEntities(ignoreCache: ignoreCache)
    }
}
