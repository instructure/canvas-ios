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
import Core

#if DEBUG
final class GetUserInteractorPreview: GetUserInteractor {
    func getUser() -> AnyPublisher<UserProfile, Error> {
        let user = UserProfile(context: AppEnvironment.shared.database.viewContext)
        user.id = "1"
        user.name = "John Doe"
        user.email = "john@doe.com"
        user.locale = "en-US"
        user.loginID = "1"
        user.pronouns = "he/him"
        user.isK5User = false

        return Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func canUpdateName() -> AnyPublisher<Bool, any Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
