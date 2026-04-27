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
import CoreData
import Foundation

protocol CoursesAndGroupsWidgetInteractor {
    typealias Model = ([CoursesAndGroupsWidgetCourseItem], [CoursesAndGroupsWidgetGroupItem])

    var showGrades: CurrentValueSubject<Bool, Never> { get }
    var showColorOverlay: CurrentValueSubject<Bool, Never> { get }

    func getCoursesAndGroups(ignoreCache: Bool, shouldForceCoursesRefresh: Bool) -> AnyPublisher<Model, Error>
    func reorderCourses(newOrder: [String])
}

extension CoursesAndGroupsWidgetInteractor where Self == CoursesAndGroupsWidgetInteractorLive {
    static func live(coursesInteractor: CoursesInteractor, env: AppEnvironment) -> CoursesAndGroupsWidgetInteractorLive {
        .init(coursesInteractor: coursesInteractor, env: env)
    }
}

final class CoursesAndGroupsWidgetInteractorLive: CoursesAndGroupsWidgetInteractor {

    let showGrades: CurrentValueSubject<Bool, Never>
    let showColorOverlay: CurrentValueSubject<Bool, Never>

    private let coursesInteractor: CoursesInteractor
    private let userSettingsStore: ReactiveStore<GetUserSettings>
    private let unreadAnnouncementCountsStore: ReactiveStore<GetUnreadCourseAnnouncementCountsUseCase>

    private let env: AppEnvironment
    private let moContext: NSManagedObjectContext
    private var subscriptions = Set<AnyCancellable>()

    private var currentDashboardCards: [DashboardCard] = []

    init(coursesInteractor: CoursesInteractor, env: AppEnvironment) {
        self.coursesInteractor = coursesInteractor
        self.env = env
        self.moContext = env.database.backgroundReadContext

        self.userSettingsStore = ReactiveStore(
            context: moContext,
            useCase: GetUserSettings(),
            environment: env
        )
        self.unreadAnnouncementCountsStore = ReactiveStore(
            context: moContext,
            useCase: GetUnreadCourseAnnouncementCountsUseCase(),
            environment: env
        )

        self.showGrades = .init(env.userDefaults?.showGradesOnDashboard ?? false)
        self.showColorOverlay = .init(true)
        observeShowGrades()
        observeShowColorOverlay()
    }

    /// Returns a tupple of course items and group items.
    ///
    /// If there are favorite courses: only the favorite and active courses are returned.
    /// Past courses or courses in invited state are excluded.
    /// If there are no favorite courses: all active and invited courses are returned.
    /// Past courses are excluded.
    /// (This uses the 'dashboard_cards' endpoint which provides an already filtered list of courses to display)
    ///
    /// If there are favorite groups: only the favorite and active groups are returned.
    /// If there are no favorite groups: no groups are returned.
    /// (This uses the 'favorites/groups' endpoint which provides an already filtered list of groups to display,
    /// but it needs to be further filtered for active courses)
    func getCoursesAndGroups(ignoreCache: Bool, shouldForceCoursesRefresh: Bool) -> AnyPublisher<Model, Error> {
        Publishers.CombineLatest3(
            coursesInteractor.getCourses(ignoreCache: ignoreCache || shouldForceCoursesRefresh),
            userSettingsStore.getEntities(ignoreCache: ignoreCache),
            unreadAnnouncementCountsStore.getEntities(ignoreCache: ignoreCache)
        )
        .map { [weak self] (coursesResult: CoursesResult, _, _) -> Model in
            let sortedCourseCards = coursesResult.courseCards.sortedForWidget()
            self?.currentDashboardCards = sortedCourseCards
            let userID = self?.env.currentSession?.userID
            let courseItems = coursesResult.allCourses
                .filterUsingDashboardCards(sortedCourseCards)
                .map { course in
                    CoursesAndGroupsWidgetCourseItem(
                        id: course.id,
                        title: course.name ?? "",
                        color: course.color.asColor,
                        imageUrl: course.imageDownloadURL,
                        grade: course.hideTotalGrade(userID: userID) ? nil : course.displayGradeForLearnerDashboard,
                        unreadAnnouncementCount: course.unreadAnnouncementCount?.unreadCount ?? 0,
                        singleUnreadAnnouncementId: course.unreadAnnouncementCount?.singleUnreadAnnouncementId
                    )
                }

            let groupItems = coursesResult.favoriteGroups.filter { $0.isActive }.map {
                CoursesAndGroupsWidgetGroupItem(
                    id: $0.id,
                    title: $0.name,
                    contextName: $0.customizedContextName,
                    groupColor: $0.color.asColor,
                    memberCount: $0.memberCount
                )
            }

            return (courseItems, groupItems)
        }
        .eraseToAnyPublisher()
    }

    func reorderCourses(newOrder: [String]) {
        guard currentDashboardCards.map(\.id) != newOrder else { return }

        for card in currentDashboardCards {
            guard let newIndex = newOrder.firstIndex(of: card.id) else {
                continue
            }
            card.position = newIndex
        }
        PutDashboardCardPositions(cards: currentDashboardCards).fetch()
    }

    private func observeShowGrades() {
        NotificationCenter.default
            .publisher(for: .showGradesOnDashboardDidChange)
            .receive(on: DispatchQueue.main)
            .map { [env] _ in
                env.userDefaults?.showGradesOnDashboard ?? false
            }
            .removeDuplicates()
            .subscribe(showGrades)
            .store(in: &subscriptions)
    }

    private func observeShowColorOverlay() {
        userSettingsStore
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .map {
                let hideColorOverlay = $0.first?.hideDashcardColorOverlays ?? false
                return !hideColorOverlay
            }
            .removeDuplicates()
            .replaceError(with: true)
            .subscribe(showColorOverlay)
            .store(in: &subscriptions)
    }
}

private extension [DashboardCard] {
    /// Sort cards first by position, then by name, then by id
    func sortedForWidget() -> [DashboardCard] {
        sorted { card1, card2 in
            if card1.position != card2.position {
                return card1.position < card2.position
            }

            if card1.shortName != card2.shortName {
                return card1.shortName < card2.shortName
            }

            return card1.id < card2.id
        }
    }
}

private extension [Course] {
    func filterUsingDashboardCards(_ cards: [DashboardCard]) -> [Course] {
        // Map the course array into a dictionary by id
        let keysAndValues = self.map { ($0.id, $0) }
        let courseMap = Dictionary(keysAndValues) { $1 }

        return cards.compactMap { courseMap[$0.id] }
    }
}
