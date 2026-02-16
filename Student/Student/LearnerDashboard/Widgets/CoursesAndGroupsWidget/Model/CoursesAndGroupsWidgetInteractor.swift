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
    private let dashboardCardsStore: ReactiveStore<GetDashboardCards>

    init(coursesInteractor: CoursesInteractor, env: AppEnvironment) {
        self.coursesInteractor = coursesInteractor

        self.dashboardCardsStore = ReactiveStore(
            context: env.database.viewContext,
            useCase: GetDashboardCards(),
            environment: env
        )
    }

    /// Returns a tupple of course items and group items.
    ///
    /// If there are favorite courses: only the favorite and active courses are returned.
    /// Past courses or courses in invited state are excluded.
    /// If there are no favorite courses: all active and invited courses are returned.
    /// Past courses are excluded.
    /// (This uses the 'dashboard_cards' endpoint which provides an already filtered list of courses to display)
    func getCoursesAndGroups(ignoreCache: Bool) -> AnyPublisher<Model, Error> {
        Publishers.CombineLatest(
            dashboardCardsStore.getEntities(ignoreCache: ignoreCache),
            coursesInteractor.getCourses(ignoreCache: ignoreCache)
        )
        .map { (cards: [DashboardCard], coursesResult: CoursesResult) -> Model in
            let courses = coursesResult.allCourses
                .filteredAndSortedUsingDashboardCards(cards)
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
    func filteredAndSortedUsingDashboardCards(_ cards: [DashboardCard]) -> [Course] {
        // Sort cards first by position, then by name, then by id
        let sortedCards = cards.sorted { card1, card2 in
            if card1.position != card2.position {
                return card1.position < card2.position
            }

            if card1.shortName != card2.shortName {
                return card1.shortName < card2.shortName
            }

            return card1.id < card2.id
        }

        // Map the course array into a dictionary by id
        let courseMap = Dictionary(uniqueKeysWithValues: self.map { ($0.id, $0) })

        return sortedCards.compactMap { courseMap[$0.id] }
    }
}
