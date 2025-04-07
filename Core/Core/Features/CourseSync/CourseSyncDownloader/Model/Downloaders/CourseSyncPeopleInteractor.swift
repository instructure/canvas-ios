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
import CombineExt

protocol CourseSyncPeopleInteractor: CourseSyncContentInteractor {}

class CourseSyncPeopleInteractorLive: CourseSyncPeopleInteractor {

    var associatedTabType: TabName { .people }

    func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {

        let context: Context = courseId.asContext

        return [
            Self.fetchCourseColors(),
            Self.fetchCourse(context: context),
            Self.fetchSections(courseID: courseId),
            Self.fetchUsers(context: context)
        ]
            .zip()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func cleanContent(courseId: CourseSyncID) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    private static func fetchCourseColors() -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCustomColors())
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchCourse(context: Context) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCourse(courseID: context.id))
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchUsers(context: Context) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetPeopleListUsers(context: context))
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchSections(courseID: CourseSyncID) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetCourseSections(courseID: courseID.localID),
            environment: courseID.env
        )
        .getEntities(ignoreCache: true)
        .mapToVoid()
        .eraseToAnyPublisher()
    }
}
