//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import UIKit

public class DashboardContainerViewModel: ObservableObject {
    // MARK: - Inputs

    public let settingsButtonTapped = PassthroughSubject<Void, Never>()

    // MARK: - Outputs

    @Published var groups = [Group]()
    public let showSettings = PassthroughSubject<(view: UIViewController, viewSize: CGSize), Never>()

    // MARK: - Private Variables

    private var subscriptions = Set<AnyCancellable>()
    private let groupListStore: ReactiveStore<GetDashboardGroups>
    private var defaults: SessionDefaults
    private let environment: AppEnvironment

    public init(
        environment: AppEnvironment,
        defaults: SessionDefaults,
        courseSyncInteractor: CourseSyncInteractor = CourseSyncDownloaderAssembly.makeInteractor()
    ) {
        self.defaults = defaults
        self.environment = environment
        settingsButtonTapped
            .map {
                let interactor = DashboardSettingsInteractorLive(environment: environment, defaults: environment.userDefaults)
                let viewModel = DashboardSettingsViewModel(interactor: interactor)
                let dashboard = CoreHostingController(DashboardSettingsView(viewModel: viewModel))
                dashboard.addDoneButton(side: .right)
                return (CoreNavigationController(rootViewController: dashboard), viewModel.popoverSize)
            }
            .subscribe(showSettings)
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: .OfflineSyncTriggered)
            .compactMap { $0.object as? [CourseSyncEntry] }
            .flatMap { courseSyncInteractor.downloadContent(for: $0) }
            .sink()
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: .OfflineSyncCleanTriggered)
            .compactMap { $0.object as? [CourseSyncID] }
            .flatMap { courseSyncInteractor.cleanContent(for: $0) }
            .sink()
            .store(in: &subscriptions)

        groupListStore = ReactiveStore(
            useCase: GetDashboardGroups()
        )

        groupListStore.getEntities(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .assign(to: &$groups)

        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .flatMap { [weak self] _ in
                self?.refreshGroups() ?? Publishers.typedJust()
            }
            .sink()
            .store(in: &subscriptions)
    }

    public func refreshGroups() -> AnyPublisher<Void, Never> {
        groupListStore.forceRefresh()
            .eraseToAnyPublisher()
    }

    // MARK: - Learner Dashboard Feedback

    public func checkAndShowFeedbackAlert(from viewController: UIViewController) {
        guard defaults.shouldShowDashboardFeedback else { return }

        defaults.shouldShowDashboardFeedback = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.createAndPresentFeedbackAlert(from: viewController)
        }
    }

    private func createAndPresentFeedbackAlert(from viewController: UIViewController) {
        let feedbackAlert = DashboardFeedbackAlert(
            onSubmit: { [weak self] reason in
                self?.submitFeedback(reason: reason)
            },
            onSkip: {},
            onLetUsKnow: { [weak self] in
                self?.presentFeedbackForm(from: viewController)
            }
        )

        let hostingController = CoreHostingController(feedbackAlert)
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        hostingController.view.backgroundColor = UIColor.black.withAlphaComponent(0.24)

        environment.router.show(
            hostingController,
            from: viewController,
            options: .modal()
        )
    }

    private func presentFeedbackForm(from viewController: UIViewController) {
        guard let topViewController = viewController.topMostViewController() else { return }

        let feedbackURL = URL(
            string: "https://instructure.com"
        )!

        let webViewController = CoreWebViewController()
        webViewController.webView.load(URLRequest(url: feedbackURL))

        environment.router.show(
            webViewController,
            from: topViewController,
            options: .modal(.formSheet, embedInNav: true, addDoneButton: true)
        )
    }

    private func submitFeedback(reason: DashboardFeedbackReason) {
        Analytics.shared.logEvent(
            "dashboard_survey_submitted",
            parameters: [
                "selected_reason": reason.analyticsValue
            ]
        )
    }
}
