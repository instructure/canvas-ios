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

@Observable
class DashboardViewModel {
    // MARK: - Outputs

    private(set) var state: InstUI.ScreenState = .loading
    var title: String = ""
    var nextUpViewModels: [NextUpViewModel] = []

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

        getCoursesInteractor.getCourses()
            .sink(receiveValue: onGetCoursesResponse(courses:))
            .store(in: &subscriptions)

        getUserInteractor.getUser()
            .map { $0.name }
            .map { "Hi, \($0)" }
            .replaceError(with: "")
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
    }

    private func onGetCoursesResponse(courses: [HCourse]) {
        self.state = .data
        self.nextUpViewModels = courses
            .filter { $0.incompleteModules.count > 0 }
            .map(toNextUpViewModel)
    }

    private func toNextUpViewModel(_ course: HCourse) -> NextUpViewModel {
        .init(
            name: course.name,
            progress: course.progress / 100.0,
            learningObjectCardViewModel: course
                .incompleteModules
                .first
                .flatMap(toLearningObjectCardViewModel)
        )
    }

    private func toLearningObjectCardViewModel(_ module: HModule) -> LearningObjectCardViewModel {
        let firstModuleItem = module.items.first
        return LearningObjectCardViewModel(
            moduleTitle: module.name,
            learningObjectName: firstModuleItem?.title ?? "",
            type: firstModuleItem?.type?.label,
            dueDate: firstModuleItem?.dueAt?.relativeShortDateOnlyString,
            url: firstModuleItem?.htmlURL
        )
    }

    // MARK: - Inputs

    func notebookDidTap(controller: WeakViewController) {
        router.route(to: "/notebook", from: controller)
    }

    func notificationsDidTap() {}

    func mailDidTap() {}

    func navigateToCourseDetails(url: URL, viewController: WeakViewController) {
        router.route(to: url, from: viewController)
    }

    struct NextUpViewModel: Identifiable {
        let name: String
        let progress: Double
        let learningObjectCardViewModel: LearningObjectCardViewModel?

        var id: String { name }
    }

    struct LearningObjectCardViewModel {
        let moduleTitle: String
        let learningObjectName: String
        let type: String?
        let dueDate: String?
        let url: URL?
    }
}
