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

    private(set) var coursesSectionTitle: String = ""
    private(set) var coursesSectionAccessibilityTitle: String = ""
    private(set) var groupsSectionTitle: String = ""
    private(set) var groupsSectionAccessibilityTitle: String = ""

    private(set) var showGrades: Bool = false
    private(set) var showColorOverlay: Bool = false

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

        updateSectionTitles()
        updateShowGrades(on: interactor.showGrades)
        updateShowColorOverlay(on: interactor.showColorOverlay)
    }

    func makeView() -> CoursesAndGroupsWidgetView {
        CoursesAndGroupsWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.getCoursesAndGroups(ignoreCache: ignoreCache)
            .map { [weak self, environment] (courseItems, groupItems) in
                guard let self else { return }
                courseCards = courseItems.map { item in
                    CourseCardViewModel(
                        model: item,
                        router: environment.router
                    )
                }

                groupCards = groupItems.compactMap { item in
                    GroupCardViewModel(
                        model: item,
                        router: environment.router
                    )
                }

                state = (courseItems.isEmpty && groupItems.isEmpty) ? .empty : .data
                updateSectionTitles()
            }
            .receive(on: DispatchQueue.main)
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    func didTapAllCourses(from controller: WeakViewController) {
        environment.router.route(to: "/courses", from: controller, options: .push)
    }

    private func updateSectionTitles() {
        let courseCount = courseCards.count
        coursesSectionTitle = String(localized: "Courses (\(courseCount))", bundle: .student)
        coursesSectionAccessibilityTitle = [
            String(localized: "Courses", bundle: .student),
            String.format(numberOfItems: courseCount)
        ].joined(separator: ", ")

        let groupCount = groupCards.count
        groupsSectionTitle = String(localized: "Groups (\(groupCount))", bundle: .student)
        groupsSectionAccessibilityTitle = [
            String(localized: "Groups", bundle: .student),
            String.format(numberOfItems: groupCount)
        ].joined(separator: ", ")
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
}

extension CoursesAndGroupsWidgetViewModel: CourseCardOrderChangeDelegate {

    func orderDidChange(_ newOrder: [CourseCardDropToReorderDelegate.CardID]) {
        courseCards = newOrder.compactMap { id in
            courseCards.first { $0.id == id }
        }
    }

    func reorderDidFinish() {
        interactor.reorderCourses(newOrder: courseCards.map(\.id))
    }
}
