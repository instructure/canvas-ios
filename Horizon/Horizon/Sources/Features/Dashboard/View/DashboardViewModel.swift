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
import HorizonUI

final class DashboardViewModel: ObservableObject {
    // MARK: - Outputs

    @Published private(set) var state: InstUI.ScreenState = .loading
    @Published private(set) var title: String = "Hi, John"
    @Published private(set) var courses: [HCourse] = []

    // MARK: - Input

    var viewController: WeakViewController = .init()

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()
    private let router: Router

    // MARK: - Init

    init(
        getCoursesInteractor: GetCoursesInteractor,
        getUserInteractor: GetUserInteractor,
        router: Router
    ) {
        self.router = router

        unowned let unownedSelf = self

        getCoursesInteractor.getCourses()
            .sink { courses in
                unownedSelf.courses = courses
                unownedSelf.state = .data
            }
            .store(in: &subscriptions)

        getUserInteractor.getUser()
            .map { $0.name }
            .map { "Hi, \($0)" }
            .replaceError(with: "")
            .assign(to: &$title)
    }

    // MARK: - Inputs

    func notebookDidTap() {
        router.route(to: "/notebook", from: viewController)
    }

    func notificationsDidTap() {}

    func mailDidTap() {}

    // MARK: - Private Functions

    func onEvent(event: HorizonUI.NavigationBar.Trailing.Event) {
        switch event {
        case .mail:
            mailDidTap()
        case .notebook:
            notebookDidTap()
        case .notification:
            notificationsDidTap()
        }
    }
}
