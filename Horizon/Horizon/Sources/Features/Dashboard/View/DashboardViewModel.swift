//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Observation

@Observable
class DashboardViewModel {
    // MARK: - Outputs

    private(set) var state: InstUI.ScreenState = .loading
    var title: String = ""
    var nextUpViewModels: [DashboardCourse] = []

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()
    private let getCoursesInteractor: GetCoursesInteractor
    private let router: Router

    // MARK: - Init

    init(
        getCoursesInteractor: GetCoursesInteractor,
        router: Router
    ) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor
        self.getCourses()
    }

    private func getCourses(
        ignoreCache: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        getCoursesInteractor.getDashboardCourses(ignoreCache: ignoreCache)
            .sink { [weak self] items in
                self?.nextUpViewModels  = items
                self?.state = .data
                completion?()
            }
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func notebookDidTap(viewController: WeakViewController) {
        router.route(to: "/notebook", from: viewController)
    }

    func notificationsDidTap(viewController: WeakViewController) {
        router.show(NotificationAssembly.makeView(), from: viewController)
    }

    func mailDidTap(viewController: WeakViewController) {
        router.route(to: "/conversations", from: viewController)
    }

    func navigateToCourseDetails(url: URL, viewController: WeakViewController) {
        router.route(to: url, from: viewController)
    }

    func reload(completion: @escaping () -> Void) {
        getCourses(
            ignoreCache: true,
            completion: completion
        )
    }

    func getStatus(percent: Double) -> String {
        switch percent {
        case 0..<1:
            return String(localized: "In Progress", bundle: .horizon)
        case 1:
            return String(localized: "Completed", bundle: .horizon)
        default:
            return String(localized: "Not Started", bundle: .horizon)
        }
    }
}
