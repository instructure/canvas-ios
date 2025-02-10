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
import CoreData

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

class UpdateUserUseCase: APIUseCase {
    var cacheKey: String?

    public typealias Response = APIProfile
    public typealias Model = UserProfile

    private let name: String?
    private let shortName: String?
    private let timeZone: String?

    init(name: String? = nil, shortName: String? = nil, timeZone: String? = nil) {
        self.name = name
        self.shortName = shortName
        self.timeZone = timeZone
    }

    public var request: PutUserInfoRequest {
        .init(name: name, shortName: shortName, timeZone: timeZone)
    }

    func write(response: APIProfile?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        UserProfile.save(response, in: client)
    }
}

struct PutUserInfoRequest: APIRequestable {
    let name: String?
    let shortName: String?
    let timeZone: String?

    typealias Response = APIProfile

    struct Body: Encodable {
        let user: User
    }
    struct User: Encodable {
        let name: String?
        let short_name: String?
        let default_time_zone: String?
    }
    let method = APIMethod.put
    let path = "users/self"
    var body: Body? {
        return Body(user: User(name: name, short_name: shortName, default_time_zone: timeZone))
    }
}
