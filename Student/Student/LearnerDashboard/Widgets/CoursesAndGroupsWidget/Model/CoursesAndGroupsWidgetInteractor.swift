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

import Combine
import Core
import Foundation

protocol CoursesAndGroupsWidgetInteractor {
    typealias Model = ([CoursesAndGroupsWidgetCourseItem], [CoursesAndGroupsWidgetGroupItem])

    func getCoursesAndGroups(ignoreCache: Bool) -> AnyPublisher<Model, Error>
}

extension CoursesAndGroupsWidgetInteractor where Self == CoursesAndGroupsWidgetInteractorLive {
    static func live(coursesInteractor: CoursesInteractor, env: AppEnvironment) -> CoursesAndGroupsWidgetInteractorLive {
        .init(coursesInteractor: coursesInteractor, env: env)
    }
}

final class CoursesAndGroupsWidgetInteractorLive: CoursesAndGroupsWidgetInteractor {

    private let coursesInteractor: CoursesInteractor
    private let cardPositionStore: ReactiveStore<GetDashboardCardPositions>

    init(coursesInteractor: CoursesInteractor, env: AppEnvironment) {
        self.coursesInteractor = coursesInteractor

        self.cardPositionStore = ReactiveStore(
            context: env.database.viewContext,
            useCase: GetDashboardCardPositions(),
            environment: env
        )
    }

    /// Returns a tupple of course items and group items.
    /// If there are favorite courses: all courses are returned, even the ones only in invited state.
    /// If there are no favorite courses: only favorite courses are returned.
    /// All groups coming from the backend are returned.
    // TODO: refine group filtering
    func getCoursesAndGroups(ignoreCache: Bool) -> AnyPublisher<Model, Error> {
        Publishers.CombineLatest(
            cardPositionStore.getEntities(ignoreCache: ignoreCache),
            coursesInteractor.getCourses(ignoreCache: ignoreCache)
        )
        .map { (positions: [CDDashboardCardPosition], coursesResult: CoursesResult) -> Model in
            let courses = coursesResult.allCourses
                .sortedUsingPositions(positions)
            let courseItems = courses.map {
                CoursesAndGroupsWidgetCourseItem(
                    id: $0.id,
                    title: $0.name ?? "",
                    color: $0.color.hexString,
                    imageUrl: $0.imageDownloadURL
                )
            }

            let groups = coursesResult.groups
            let groupItems = groups.map {
                CoursesAndGroupsWidgetGroupItem(
                    id: $0.id,
                    title: $0.name,
                    courseName: $0.course?.name ?? "",
                    color: $0.color.hexString
                )
            }

            return (courseItems, groupItems)
        }
        .eraseToAnyPublisher()
    }
}

private extension [Course] {
    func sortedUsingPositions(_ positions: [CDDashboardCardPosition]) -> [Course] {
        // Map the array of card position objects into a dictionary of positions
        let positionMap = Dictionary(uniqueKeysWithValues: positions.map { ($0.courseCode, $0.position) })

        // Sort courses by position. Move courses without position to the end.
        return self.sorted { course1, course2 in
            let position1 = positionMap[course1.canvasContextID]
            let position2 = positionMap[course2.canvasContextID]

            switch (position1, position2) {
            case let (.some(p1), .some(p2)):
                return p1 < p2
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return false
            }
        }
    }
}
