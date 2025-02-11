//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

protocol UpdateUserProfileInteractor {
    func set(
        name: String,
        shortName: String
    ) -> AnyPublisher<UserProfile?, Never>

    func set(timeZone: String) -> AnyPublisher<UserProfile?, Never>
}

class UpdateUserProfileInteractorLive: UpdateUserProfileInteractor {

    private let api: API

    init(api: API = AppEnvironment.shared.api) {
        self.api = api
    }

    func set(
        name: String,
        shortName: String
    ) -> AnyPublisher<UserProfile?, Never> {
        ReactiveStore(useCase: UpdateUserUseCase(name: name, shortName: shortName))
            .getEntities()
            .replaceError(with: [])
            .map { $0.first }
            .eraseToAnyPublisher()
    }

    func set(timeZone: String) -> AnyPublisher<UserProfile?, Never> {
        ReactiveStore(useCase: UpdateUserUseCase(timeZone: timeZone))
            .getEntities()
            .replaceError(with: [])
            .map { $0.first }
            .eraseToAnyPublisher()
    }
}
