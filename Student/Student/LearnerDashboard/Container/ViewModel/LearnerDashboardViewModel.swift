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
import CombineSchedulers
import Core
import Foundation
import Observation
import SwiftUI
import UIKit

@Observable
final class LearnerDashboardViewModel {
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var widgets: [any DashboardWidgetViewModel] = []
    private(set) var mainColor: Color
    let snackBarViewModel: SnackBarViewModel

    let screenConfig = InstUI.BaseScreenConfig(
        refreshable: true,
        showsScrollIndicators: false,
        emptyPandaConfig: .init(
            scene: SpacePanda(),
            title: String(localized: "Welcome to Canvas!", bundle: .student),
            subtitle: String(
                localized: "You don't have any courses yet — so things are a bit quiet here. Once you enroll in a class, your dashboard will start filling up with new activity.",
                bundle: .student
            )
        ),
        backgroundColor: .backgroundLight
    )

    private let interactor: LearnerDashboardInteractor
    private let colorInteractor: LearnerDashboardColorInteractor
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()
    private let courseSyncInteractor: CourseSyncInteractor
    private let environment: AppEnvironment

    init(
        interactor: LearnerDashboardInteractor,
        colorInteractor: LearnerDashboardColorInteractor,
        snackBarViewModel: SnackBarViewModel,
        mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
        courseSyncInteractor: CourseSyncInteractor = CourseSyncDownloaderAssembly.makeInteractor(),
        environment: AppEnvironment
    ) {
        self.interactor = interactor
        self.colorInteractor = colorInteractor
        self.snackBarViewModel = snackBarViewModel
        self.mainScheduler = mainScheduler
        self.courseSyncInteractor = courseSyncInteractor
        self.environment = environment
        self.mainColor = colorInteractor.dashboardColor.value

        loadWidgets()
        setupOfflineSyncHandlers()
        observeColorChanges()
    }

    func refresh(ignoreCache: Bool, completion: (() -> Void)? = nil) {
        let publishers = widgets.map { $0.refresh(ignoreCache: ignoreCache) }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: mainScheduler)
            .sink { [weak self] _ in
                guard self != nil else { return }
                completion?()
            }
            .store(in: &subscriptions)
    }

    func makeSettingsViewModel() -> LearnerDashboardSettingsViewModel {
        LearnerDashboardSettingsAssembly.makeViewModel(
            env: environment,
            colorInteractor: colorInteractor,
            onConfigsChanged: { [weak self] in self?.loadWidgets() }
        )
    }

    // MARK: - Private Methods

    private func observeColorChanges() {
        colorInteractor.dashboardColor
            .receive(on: mainScheduler)
            .sink { [weak self] color in self?.mainColor = color }
            .store(in: &subscriptions)
    }

    private func loadWidgets() {
        interactor.loadWidgets()
            .receive(on: mainScheduler)
            .sink { [weak self] result in
                guard let self else { return }
                widgets = result
                if result.isNotEmpty {
                    state = .data
                }
                refresh(ignoreCache: false)
            }
            .store(in: &subscriptions)
    }

    private func setupOfflineSyncHandlers() {
        NotificationCenter.default.publisher(for: .OfflineSyncTriggered)
            .compactMap { $0.object as? [CourseSyncEntry] }
            .flatMap { [courseSyncInteractor] in
                courseSyncInteractor.downloadContent(for: $0)
            }
            .sink()
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: .OfflineSyncCleanTriggered)
            .compactMap { $0.object as? [CourseSyncID] }
            .flatMap { [courseSyncInteractor] in
                courseSyncInteractor.cleanContent(for: $0)
            }
            .sink()
            .store(in: &subscriptions)
    }
}
