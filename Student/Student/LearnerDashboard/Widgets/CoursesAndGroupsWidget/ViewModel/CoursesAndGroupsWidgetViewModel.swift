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

@Observable
final class CoursesAndGroupsWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = CoursesAndGroupsWidgetView

    let config: DashboardWidgetConfig
    let isFullWidth = false
    let isEditable = false

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var courseCards: [CourseCardViewModel] = []
    private(set) var groupCards: [GroupCardViewModel] = []
    private(set) var widgetTitle: String = ""
    private(set) var widgetAccessibilityTitle: String = ""

    var layoutIdentifier: [AnyHashable] {
        [state, courseCards.count, groupCards.count]
    }

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

        updateWidgetTitle()
    }

    func makeView() -> CoursesAndGroupsWidgetView {
        CoursesAndGroupsWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.getCoursesAndGroups(ignoreCache: ignoreCache)
            .map { [weak self] (courseItems, groupItems) in
                self?.courseCards = courseItems.map { item in
                    return CourseCardViewModel(model: item) { controller in
                        self?.showCourseDetails(for: item, from: controller)
                    }
                }

                self?.groupCards = groupItems.compactMap { item in
                    return GroupCardViewModel(model: item) { controller in
                        self?.showGroupDetails(for: item, from: controller)
                    }
                }

                self?.state = (courseItems.isEmpty && groupItems.isEmpty) ? .empty : .data
                self?.updateWidgetTitle()
            }
            .receive(on: DispatchQueue.main)
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    private func showCourseDetails(for item: CoursesAndGroupsWidgetCourseItem, from controller: WeakViewController) {
        let route: String
        if let colorWithoutHash = item.color?.dropFirst() {
            route = "/courses/\(item.id)?contextColor=\(colorWithoutHash)"
        } else {
            route = "/courses/\(item.id)"
        }

        environment.router.route(to: route, from: controller)
    }

    private func showGroupDetails(for item: CoursesAndGroupsWidgetGroupItem, from controller: WeakViewController) {
        let route = "/groups/\(item.id)"
        environment.router.route(to: route, from: controller)
    }

    private func updateWidgetTitle() {
        let courseCount = courseCards.count
        let groupCount = groupCards.count
        widgetTitle = String(localized: "Courses & Groups", bundle: .student)
        widgetAccessibilityTitle = [
            String(localized: "Courses", bundle: .student),
            String.format(numberOfItems: courseCount),
            String(localized: "Groups", bundle: .student),
            String.format(numberOfItems: groupCount)
        ].joined(separator: ", ")
    }
}
