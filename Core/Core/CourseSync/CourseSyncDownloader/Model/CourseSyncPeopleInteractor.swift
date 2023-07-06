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

protocol CourseSyncPeopleInteractor: CourseSyncContentInteractor {}

class CourseSyncPeopleInteractorLive: CourseSyncPeopleInteractor {

    var associatedTabType: TabName { .people }

    private var context: Context!

    func getContent(courseId: String) -> AnyPublisher<Void, Error> {

        context = .course(courseId)

        return Publishers
            .Zip4(
                Self.fetchCourseColors(),
                Self.fetchCourse(context: context),
                Self.fetchGroup(context: context),
                Self.fetchUsers(context: context)
            )
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchCourseColors() -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCustomColors())
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchCourse(context: Context) -> AnyPublisher<Course?, Error> {
        ReactiveStore(useCase: GetCourse(courseID: context.id))
            .getEntities()
            .map { $0.first }
            .eraseToAnyPublisher()
    }

    private static func fetchGroup(context: Context) -> AnyPublisher<[User], Error> {
        ReactiveStore(useCase: GetContextUsers(context: context))
            .getEntities()
            .eraseToAnyPublisher()
    }

    private static func fetchUsers(context: Context) -> AnyPublisher<Group?, Error> {
        ReactiveStore(useCase: GetGroup(groupID: context.id))
            .getEntities()
            .map { $0.first }
            .eraseToAnyPublisher()
    }
}

