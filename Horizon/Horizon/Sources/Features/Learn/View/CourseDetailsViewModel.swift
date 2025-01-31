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

@Observable
final class CourseDetailsViewModel {
    // MARK: - Outputs

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var title: String = "Biology certificate"
    private(set) var course: HCourse

    // MARK: - Private

    private let onShowTabBar: (Bool) -> Void
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        router: Router,
        getCoursesInteractor: GetCoursesInteractor,
        course: HCourse,
        onShowTabBar: @escaping (Bool) -> Void
    ) {
        self.router = router
        self.course = course
        self.onShowTabBar = onShowTabBar

        self.state = .data

        getCoursesInteractor.getCourse(id: course.id)
            .sink { [weak self] course in
                guard let course = course, let self = self else { return }
                self.course = course
            }
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func moduleItemDidTap(url: URL, from: WeakViewController) {
        router.route(to: url, from: from)
    }

    func showTabBar() {
        onShowTabBar(true)
    }
}
