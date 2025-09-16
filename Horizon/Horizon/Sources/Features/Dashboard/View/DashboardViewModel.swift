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
    private(set) var courses: [HCourse] = []
    private(set) var unenrolledPrograms: [Program] = []
    private(set) var invitedCourses: [InvitedCourse] = []
    private(set) var hasUnreadNotification = false
    private(set) var hasUnreadInboxMessage = false

    // MARK: - Input / Outputs

    var isAlertPresented = false

    // MARK: - Dependencies

    private let dashboardInteractor: DashboardInteractor
    private let notificationInteractor: NotificationInteractor

    private let programInteractor: ProgramInteractor
    private let router: Router

    // MARK: - Private variables

    private var getDashboardCoursesCancellable: AnyCancellable?
    private var refreshCompletedModuleItemCancellable: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    private var programs: [Program] = []

    // MARK: - Init

    init(
        dashboardInteractor: DashboardInteractor,
        notificationInteractor: NotificationInteractor,
		programInteractor: ProgramInteractor,
        router: Router
    ) {
        self.dashboardInteractor = dashboardInteractor
        self.notificationInteractor = notificationInteractor
		self.programInteractor = programInteractor
        self.router = router
        getCourses()
        setNotificationBadge()
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

        getDashboardCoursesCancellable = dashboardInteractor.getAndObserveCoursesWithoutModules(ignoreCache: ignoreCache)
            .combineLatest(programInteractor.getProgramsWithObserving(ignoreCache: ignoreCache))
            .sink { [weak self] items, programs in
                let courses = items.filter { $0.state == HCourse.EnrollmentState.active.rawValue }
                self?.courses = self?.getAttachedPrograms(to: courses, from: programs) ?? []
                self?.unenrolledPrograms = programs.filter { !$0.hasEnrolledCourse  }
                let invitedCourses = items.filter { $0.state == HCourse.EnrollmentState.invited.rawValue }
                let message = String(localized: "You have been invited to join", bundle: .horizon)
                self?.invitedCourses = invitedCourses.map { .init(id: $0.id, name: "\(message) \($0.name)", enrollmentID: $0.enrollmentID) }
                self?.state = .data
                completion?()
            }

        refreshCompletedModuleItemCancellable = dashboardInteractor.refreshModuleItemsUponCompletions()
            .sink()
    }

    private func setNotificationBadge() {
        Publishers.Zip(
            notificationInteractor.getUnreadNotificationCount(),
            dashboardInteractor.getUnreadInboxMessageCount()
        )
        .sink { [weak self] notificationCount, inboxCount in
            self?.hasUnreadNotification = notificationCount > 0
            self?.hasUnreadInboxMessage = inboxCount > 0
            TabBarBadgeCounts.unreadActivityStreamCount = UInt(notificationCount)
            TabBarBadgeCounts.unreadMessageCount = UInt(inboxCount)
        }
        .store(in: &subscriptions)
    }
 private func getAttachedPrograms(to hcourses: [HCourse], from programs: [Program]) -> [HCourse] {
        return hcourses.map { hcourse in
            var updateCourse = hcourse
            // Find all programs that contain this course id
            let matchedPrograms = programs.filter { program in
                program.courses.contains { $0.id == hcourse.id }
            }
            updateCourse.programs = matchedPrograms
            return updateCourse
        }


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

    func navigateToItemSequence(
        url: URL,
        learningObject: HCourse.LearningObjectCard,
        viewController: WeakViewController
    ) {
        let moduleItem = HModuleItem(
            id: learningObject.learningObjectID,
            title: learningObject.learningObjectName,
            htmlURL: learningObject.url,
            /// `isCompleted` is set to `false` because this is the next module item
            /// the learner must complete. If it were `true`, it would no longer appear here.
            isCompleted: false
        )
        router.route(to: url, userInfo: ["moduleItem": moduleItem], from: viewController)
    }

    func navigateToCourseDetails(
        id: String,
        enrollmentID: String,
        programID: String?,
        viewController: WeakViewController
    ) {
        router.show(
                LearnAssembly.makeCourseDetailsViewController(
                    courseID: id,
                    enrollmentID: enrollmentID,
                    programID: programID
                ),
                from: viewController
            )
    }

    func navigateProgram(id: String, viewController: WeakViewController) {
        router.show(LearnAssembly.makeLearnView(programID: id, isBackButtonVisible: true), from: viewController)
    }

    func acceptInvitation(course: InvitedCourse) {
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

    func declineInvitation(course: InvitedCourse) {
        invitedCourses.removeAll(where: { $0.id == course.id })
    }

    func reload(completion: @escaping () -> Void) {
        getCourses(
            ignoreCache: true,
            completion: completion
        )
    }

    func reloadUnreadBadges() {
        setNotificationBadge()
    }

    func getStatus(percent: Double) -> String {
        switch percent {
        case 0 ..< 1:
            return String(localized: "In progress", bundle: .horizon)
        case 1:
            return String(localized: "Completed", bundle: .horizon)
        default:
            return String(localized: "Not started", bundle: .horizon)
        }
    }
}
