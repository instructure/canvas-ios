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
    var title: String = "Hi, John"
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
            .sink(receiveValue: onGetCoursesResponse(courseProgressions:))
            .store(in: &subscriptions)

        getUserInteractor.getUser()
            .map { $0.name }
            .map { "Hi, \($0)" }
            .replaceError(with: "")
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
    }

    private func onGetCoursesResponse(courseProgressions: [CDCourseProgression]) {
        self.nextUpViewModels = toNextUpViewModels(courseProgressions)
        self.state = .data
    }

    private func toNextUpViewModels(_ courseProgressions: [CDCourseProgression]) -> [NextUpViewModel] {
        courseProgressions
            .filter { $0.modules.isEmpty == false }
            .map(toNextUpViewModel)
    }

    private func toNextUpViewModel(_ courseProgression: CDCourseProgression) -> NextUpViewModel {
        .init(
            name: courseProgression.course.name ?? "",
            progress: courseProgression.completionPercentage / 100.0,
            learningObjectCardViewModel: courseProgression
                .modules
                .first
                .flatMap(toLearningObjectCardViewModel)
        )
    }

    private func toLearningObjectCardViewModel(_ module: Module) -> LearningObjectCardViewModel {
        let firstLearningObject = module.items.first
        return LearningObjectCardViewModel(
            moduleTitle: module.name,
            learningObjectName: firstLearningObject?.title ?? "",
            type: firstLearningObject?.type?.label,
            dueDate: firstLearningObject?.dueAt?.relativeShortDateOnlyString,
            url: firstLearningObject?.htmlURL
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
