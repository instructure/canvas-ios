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
import Foundation

public protocol CourseSyncConferencesInteractor: CourseSyncContentInteractor {}

extension CourseSyncConferencesInteractor {
    public var associatedTabType: TabName { .conferences }
}

public final class CourseSyncConferencesInteractorLive: CourseSyncConferencesInteractor {

    let envResolver: CourseSyncEnvironmentResolver

    init(envResolver: CourseSyncEnvironmentResolver) {
        self.envResolver = envResolver
    }

    public func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        let environment = envResolver.targetEnvironment(for: courseId)
        return Publishers
            .Zip3(fetchColors(env: environment),
                  fetchConferences(courseId: courseId, env: environment),
                  fetchCourse(courseId: courseId, env: environment))
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func cleanContent(courseId: CourseSyncID) -> AnyPublisher<Void, Never> {
        return Just(()).eraseToAnyPublisher()
    }

    private func fetchColors(env: AppEnvironment) -> AnyPublisher<Void, Error> {
        fetchUseCase(GetCustomColors(), env)
    }

    private func fetchConferences(courseId: CourseSyncID, env: AppEnvironment) -> AnyPublisher<Void, Error> {
        fetchUseCase(GetConferences(context: courseId.asContext), env)
    }

    private func fetchCourse(courseId: CourseSyncID, env: AppEnvironment) -> AnyPublisher<Void, Error> {
        fetchUseCase(GetCourse(courseID: courseId.localID), env)
    }

    private func fetchUseCase<U: UseCase>(_ useCase: U, _ env: AppEnvironment) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: useCase, environment: env)
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
