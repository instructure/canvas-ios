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
    private(set) var errorMessage = ""
    var title: String = ""
    private(set) var courses: [DashboardCourse] = []
    private(set) var invitedCourses: [InvistedCourse] = []
    // MARK: - Input / Outputs

    var isAlertPresented = false

    // MARK: - Dependencies

    private let getCoursesInteractor: GetCoursesInteractor
    private let router: Router

    // MARK: - Private variables

    private var getDashboardCoursesCancellable: AnyCancellable?
    private var refreshCompletedModuleItemCancellable: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        getCoursesInteractor: GetCoursesInteractor,
        router: Router
    ) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor
        getCourses()
    }

    deinit {
        getDashboardCoursesCancellable?.cancel()
        getDashboardCoursesCancellable = nil
        refreshCompletedModuleItemCancellable?.cancel()
        refreshCompletedModuleItemCancellable = nil
    }

    private func getCourses(
        ignoreCache: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        getDashboardCoursesCancellable?.cancel()
        refreshCompletedModuleItemCancellable?.cancel()

        getDashboardCoursesCancellable = getCoursesInteractor.getDashboardCourses(ignoreCache: ignoreCache)
            .sink { [weak self] items in
                self?.courses = items.filter({ $0.state == DashboardCourse.EnrollmentState.active.rawValue })
                let invitedCourses = items.filter({ $0.state == DashboardCourse.EnrollmentState.invited.rawValue  })
                let message = String(localized: "You have been invited to join", bundle: .horizon)
                self?.invitedCourses = invitedCourses.map { .init(id: $0.courseId, name: "\(message) \($0.name)", enrollmentID: $0.enrollmentID) }
                self?.state = .data
                completion?()
            }

        refreshCompletedModuleItemCancellable = getCoursesInteractor.refreshModuleItemsUponCompletions()
            .sink()
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

    func navigateToItemSequence(url: URL, viewController: WeakViewController) {
        router.route(to: url, from: viewController)
    }

    func navigateToCourseDetails(id: String, viewController: WeakViewController) {
        router.route(to: "/courses/\(id)", from: viewController)
    }

    func acceptInvitation(course: InvistedCourse) {
        state = .loading
        let useCase = HandleCourseInvitation(
            courseID: course.id,
            enrollmentID: course.enrollmentID,
            isAccepted: true
        )
        ReactiveStore(useCase: useCase)
            .getEntities()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.state = .data
                    self?.errorMessage = error.localizedDescription
                    self?.isAlertPresented = true
                }

            }, receiveValue: { [weak self] _ in
                self?.reload(completion: {})
                self?.declineInvitation(course: course)
            })
            .store(in: &subscriptions)
    }

    func declineInvitation(course: InvistedCourse) {
        invitedCourses.removeAll(where: { $0.id == course.id } )
    }

    func reload(completion: @escaping () -> Void) {
        getCourses(
            ignoreCache: true,
            completion: completion
        )
    }

    func getStatus(percent: Double) -> String {
        switch percent {
        case 0 ..< 1:
            return String(localized: "In Progress", bundle: .horizon)
        case 1:
            return String(localized: "Completed", bundle: .horizon)
        default:
            return String(localized: "Not Started", bundle: .horizon)
        }
    }
}
