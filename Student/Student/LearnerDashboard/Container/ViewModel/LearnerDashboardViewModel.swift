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

@Observable
final class LearnerDashboardViewModel {
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var fullWidthWidgets: [any LearnerWidgetViewModel] = []
    private(set) var gridWidgets: [any LearnerWidgetViewModel] = []

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
        )
    )

    private let interactor: LearnerDashboardInteractor
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    init(
        interactor: LearnerDashboardInteractor,
        mainScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()
    ) {
        self.interactor = interactor
        self.mainScheduler = mainScheduler

        loadWidgets()
    }

    private func loadWidgets() {
        interactor.loadWidgets()
            .receive(on: mainScheduler)
            .sink { [weak self] result in
                guard let self else { return }
                self.fullWidthWidgets = result.fullWidth
                self.gridWidgets = result.grid
                if !result.fullWidth.isEmpty || !result.grid.isEmpty {
                    self.state = .data
                }
                self.refresh(ignoreCache: false)
            }
            .store(in: &subscriptions)
    }

    func refresh(ignoreCache: Bool, completion: (() -> Void)? = nil) {
        let allWidgets = fullWidthWidgets + gridWidgets
        let publishers = allWidgets.map { $0.refresh(ignoreCache: ignoreCache) }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: mainScheduler)
            .sink { [weak self] _ in
                guard self != nil else { return }
                completion?()
            }
            .store(in: &subscriptions)
    }
}
