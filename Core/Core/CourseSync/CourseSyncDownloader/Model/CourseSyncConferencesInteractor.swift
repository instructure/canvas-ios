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
    public init() {}

    public func getContent(courseId: String) -> AnyPublisher<Void, Error> {
        Publishers
            .Zip3(fetchColors(),
                  fetchConferences(courseId: courseId),
                  fetchCourse(courseId: courseId))
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func fetchColors() -> AnyPublisher<Void, Error> {
        fetchUseCase(GetCustomColors())
    }

    private func fetchConferences(courseId: String) -> AnyPublisher<Void, Error> {
        fetchUseCase(GetConferences(context: .course(courseId)))
    }

    private func fetchCourse(courseId: String) -> AnyPublisher<Void, Error> {
        fetchUseCase(GetCourse(courseID: courseId))
    }

    private func fetchUseCase<U: UseCase>(_ useCase: U) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
