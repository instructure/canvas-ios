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
    private(set) var course: HCourse = .init()

    // MARK: - Private

    private let router: Router
    private let onShowTabBar: (Bool) -> Void
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        router: Router,
        courseId: String,
        onShowTabBar: @escaping (Bool) -> Void,
        getCoursesInteractor: GetCoursesInteractor = GetCoursesInteractorLive()
    ) {
        self.router = router
        self.onShowTabBar = onShowTabBar
        self.state = .data

        getCoursesInteractor.getCourse(id: courseId)
            .sink { courseProgression in
                guard let courseProgression = courseProgression else { return }
                self.course = .init(courseProgression)
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

extension HCourse {
    init(_ courseProgression: CDCourseProgression) {
        self.id = courseProgression.courseID
        self.name = courseProgression.course.name ?? ""
        self.overviewDescription = ""
        self.progress = courseProgression.completionPercentage / 100.0
        self.modules = courseProgression.modules.map { .init($0) }
    }
}

extension HModule {
    init(_ module: Module) {
        let moduleItems = module.items.map { HModuleItem($0) }

        self.id = module.id
        self.name = module.name
        self.courseID = module.courseID
        self.items = moduleItems
        self.moduleStatus = .init(
            items: moduleItems,
            state: module.state,
            lockMessage: nil,
            countOfPrerequisite: 0
        )
    }
}

extension HModuleItem {
    init(_ moduleItem: ModuleItem) {
        self.init(
            id: moduleItem.id,
            title: moduleItem.title
        )
    }
}
