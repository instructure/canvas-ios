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
    var nextUpViewModels: [NextUpViewModel] = []

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()
    private let getCoursesInteractor: GetCoursesInteractor
    private let router: Router

    // MARK: - Init

    init(
        getCoursesInteractor: GetCoursesInteractor,
        getUserInteractor: GetUserInteractor,
        router: Router
    ) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor
        getCourses()

        getUserInteractor.getUser()
            .map { $0.name }
            .map { "Hi, \($0)" }
            .replaceError(with: "")
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
    }

    private func getCourses(
        ignoreCache: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        getCoursesInteractor.getCourses(ignoreCache: ignoreCache)
            .sink { [weak self] courses in
                self?.onGetCoursesResponse(courses: courses)
                completion?()
            }
            .store(in: &subscriptions)
    }

    private func onGetCoursesResponse(courses: [HCourse]) {
        state = .data
        nextUpViewModels = courses
            .filter { $0.incompleteModule != nil }
            .map(toNextUpViewModel)
    }

    private func toNextUpViewModel(_ course: HCourse) -> NextUpViewModel {
        .init(
            name: course.name,
            progress: course.progress / 100.0,
            learningObjectCardViewModel: course
                .incompleteModule
                .map { toLearningObjectCardViewModel($0, course: course) }
        )
    }

    private func toLearningObjectCardViewModel(
        _ module: IncompleteModule,
        course: HCourse
    ) -> LearningObjectCardViewModel {
        /// Get the estimated time and type because they are not available in incompleteModules, which is retrieved from GraphQL.
        let moduleItems = course.modules.first(where: { $0.id == module.moduleId })
        let item = moduleItems?.items.first(where: { $0.id == module.moduleItemId })

        return LearningObjectCardViewModel(
            moduleTitle: moduleItems?.name ?? "",
            learningObjectName: item?.title ?? "",
            type: item?.type?.label,
            dueDate: item?.dueAt?.relativeShortDateOnlyString,
            url: item?.htmlURL,
            estimatedTime: item?.estimatedDurationFormatted
        )
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
        let estimatedTime: String?
    }
}
