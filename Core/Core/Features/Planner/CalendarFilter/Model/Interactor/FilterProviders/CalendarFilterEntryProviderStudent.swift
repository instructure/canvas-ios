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

struct CalendarFilterEntryProviderStudent: CalendarFilterEntryProvider {
    private let userName: String?
    private let userId: String?

    init(
        userName: String? = AppEnvironment.shared.currentSession?.userName,
        userId: String? = AppEnvironment.shared.currentSession?.userID
    ) {
        self.userName = userName
        self.userId = userId
    }

    func make(ignoreCache: Bool) -> AnyPublisher<[CDCalendarFilterEntry], Error>? {
        guard let userName, let userId else {
            return nil
        }

        let useCase = GetStudentCalendarFilters(
            currentUserName: userName,
            currentUserId: userId,
            states: [.current_and_concluded],
            filterUnpublishedCourses: true
        )
        return ReactiveStore(useCase: useCase).getEntities(ignoreCache: ignoreCache)
    }
}
