//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import CombineSchedulers
import Core
import Foundation
import Observation

@Observable
final class AccountViewModel {
    // MARK: - Init / Outputs

    var isBugSubmitted = false
    var onReportBugDismissed = false

    // MARK: - Outputs

    private(set) var name: String = ""
    private(set) var helpItems: [HelpModel] = []
    var isShowingLogoutConfirmationAlert = false
    var isExperienceSwitchAvailable = false
    var isLoading = false

    // MARK: - Dependencies

    private let router: Router
    private let getUserInteractor: GetUserInteractor
    private let appExperienceInteractor: ExperienceSummaryInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Private properties

    public let confirmLogoutViewModel = ConfirmationAlertViewModel(
        title: String(localized: "Logout", bundle: .core),
        message: String(localized: "Are you sure you want to log out?", bundle: .core),
        cancelButtonTitle: String(localized: "No", bundle: .core),
        confirmButtonTitle: String(localized: "Yes", bundle: .core),
        isDestructive: false
    )
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        router: Router = AppEnvironment.shared.router,
        getUserInteractor: GetUserInteractor,
        appExperienceInteractor: ExperienceSummaryInteractor = ExperienceSummaryInteractorLive(),
        sessionInteractor: SessionInteractor = SessionInteractor(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.router = router
        self.getUserInteractor = getUserInteractor
        self.appExperienceInteractor = appExperienceInteractor
        self.scheduler = scheduler
        getAccountHelpLinks()
        confirmLogoutViewModel.userConfirmation()
            .sink {
                sessionInteractor.logout()
            }
            .store(in: &subscriptions)

        appExperienceInteractor
            .isExperienceSwitchAvailable()
            .assign(to: \.isExperienceSwitchAvailable, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }

   private func getAccountHelpLinks() {
        ReactiveStore(useCase: GetCareerHelpUseCase())
            .getEntities()
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map { HelpModel(entity: $0) }
            .collect()
            .map { models in models.sorted { $0.isBugReport && !$1.isBugReport } }
            .receive(on: scheduler)
            .sink { [weak self] models in
                self?.helpItems = models
            }
            .store(in: &subscriptions)
    }

    func profileDidTap(viewController: WeakViewController) {
        if let url = URL(string: "/account/profile") {
            router.route(to: url, from: viewController)
        }
    }

    func getUserName() {
        getUserInteractor
            .getUser()
            .map { $0.name }
            .replaceError(with: "")
            .assign(to: \.name, on: self)
            .store(in: &subscriptions)
    }

    func passwordDidTap() {}

    func notificationsDidTap(viewController: WeakViewController) {
        router.route(to: "/notification-settings", from: viewController)
    }

    func advancedDidTap(viewController: WeakViewController) {
        if let url = URL(string: "/account/advanced") {
            router.route(to: url, from: viewController)
        }
    }

    func switchExperienceDidTap() {
        isLoading = true

        appExperienceInteractor.switchExperience(to: Experience.academic)
            .sink { _ in
                AppEnvironment.shared.switchExperience(.academic)
                let academicInterfaceStyle = AppEnvironment.shared.userDefaults?.academicInterfaceStyle ?? .light
                AppEnvironment.shared.window?.updateInterfaceStyleWithoutTransition(academicInterfaceStyle)
                AppEnvironment.shared.userDefaults?.interfaceStyle = academicInterfaceStyle
            }
            .store(in: &subscriptions)
    }

    func betaCommunityDidTap() {}

    func giveFeedbackDidTap(viewController: WeakViewController, help: HelpModel) {
        if help.isBugReport {
            let bugView = ReportBugAssembly.makeViewConroller(
                didSubmitBug: { [weak self] in
                    self?.isBugSubmitted = true
                },
                didDismiss: { [weak self] in
                    self?.onReportBugDismissed = true
                }
            )
            router.show(bugView, from: viewController, options: .modal(.custom))
            return
        }

        guard let url = help.url else { return }
        router.route(to: url, from: viewController)
    }

    func logoutDidTap() {
        isShowingLogoutConfirmationAlert = true
    }
}
