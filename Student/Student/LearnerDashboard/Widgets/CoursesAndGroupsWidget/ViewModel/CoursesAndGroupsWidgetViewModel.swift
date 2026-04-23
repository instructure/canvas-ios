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
import SwiftUI

@Observable
final class CoursesAndGroupsWidgetViewModel: DashboardWidgetViewModel, DashboardMutatorWidget {

    let config: DashboardWidgetConfig
    var id: String { config.id.rawValue }
    let isHiddenInEmptyState = false

    private(set) var state: ScreenState = .loading
    private(set) var courseCards: [CourseCardViewModel] = [
        .placeholder(id: "1", color: .course1),
        .placeholder(id: "2", color: .course2),
        .placeholder(id: "3", color: .course3)
    ]
    private(set) var groupCards: [GroupCardViewModel] = []

    private(set) var showGrades: Bool = false
    private(set) var showColorOverlay: Bool = false

    private var favoritesDidChange: Bool = false

    var layoutIdentifier: [AnyHashable] {
        [state, courseCards.count, groupCards.count]
    }

    var requestDashboardRefresh = PassthroughSubject<Void, Never>()

    private let interactor: CoursesAndGroupsWidgetInteractor
    private let environment: AppEnvironment

    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        interactor: CoursesAndGroupsWidgetInteractor,
        environment: AppEnvironment = .shared
    ) {
        self.config = config
        self.interactor = interactor
        self.environment = environment

        updateShowGrades(on: interactor.showGrades)
        updateShowColorOverlay(on: interactor.showColorOverlay)
        observeFavoritesDidChange()
    }

    func makeView() -> AnyView {
        AnyView(CoursesAndGroupsWidgetView(viewModel: self))
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        // Favorite changes require refresh from API, because those can't be applied properly on client side.
        let shouldForceCoursesRefresh = favoritesDidChange
        favoritesDidChange = false

        if shouldForceCoursesRefresh {
            state = .loading
        }

        return interactor.getCoursesAndGroups(ignoreCache: ignoreCache, shouldForceCoursesRefresh: shouldForceCoursesRefresh)
            .receive(on: DispatchQueue.main)
            .map { [weak self, environment] (courseItems, groupItems) in
                guard let self else { return }
                courseCards = courseItems.map { item in
                    CourseCardViewModel(
                        model: item,
                        didSaveChanges: self.requestDashboardRefresh,
                        router: environment.router
                    )
                }

                groupCards = groupItems.compactMap { item in
                    GroupCardViewModel(
                        model: item,
                        router: environment.router,
                        environment: environment
                    )
                }

                state = (courseItems.isEmpty && groupItems.isEmpty) ? .empty : .data
            }
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    func didTapAllCourses(from controller: WeakViewController) {
        environment.router.route(to: "/courses", from: controller, options: .push)
    }

    private func updateShowGrades(on subject: CurrentValueSubject<Bool, Never>) {
        subject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.showGrades = $0
            }
            .store(in: &subscriptions)
    }

    private func updateShowColorOverlay(on subject: CurrentValueSubject<Bool, Never>) {
        subject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.showColorOverlay = $0
            }
            .store(in: &subscriptions)
    }

    private func observeFavoritesDidChange() {
        NotificationCenter.default
            .publisher(for: .favoritesDidChange)
            .sink { [weak self] _ in
                self?.favoritesDidChange = true
            }
            .store(in: &subscriptions)
    }
}

extension CoursesAndGroupsWidgetViewModel: CourseCardOrderChangeDelegate {

    func orderDidChange(_ newOrder: [CourseCardDropToReorderDelegate.CardID]) {
        courseCards = newOrder.compactMap { id in
            courseCards.first { $0.courseID == id }
        }
    }

    func reorderDidFinish() {
        interactor.reorderCourses(newOrder: courseCards.map(\.courseID))
    }
}
