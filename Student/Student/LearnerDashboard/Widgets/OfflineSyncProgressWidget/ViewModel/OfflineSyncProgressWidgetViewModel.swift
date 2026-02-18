//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import SwiftUI

@Observable
final class OfflineSyncProgressWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = OfflineSyncProgressWidgetView

    // MARK: - Protocol Properties

    let config: DashboardWidgetConfig
    private(set) var state: InstUI.ScreenState = .empty
    let isFullWidth = true
    let isEditable = false

    var layoutIdentifier: [AnyHashable] {
        [state, progress, progressText, title]
    }

    // MARK: - Public Properties

    private(set) var progress: Float = 0
    private(set) var progressText: String = ""
    private(set) var backgroundColor: Color = .backgroundDarkest
    private(set) var title: String?
    private(set) var subtitleText: String?

    // MARK: - Private Properties

    private let dashboardViewModel: DashboardOfflineSyncProgressCardViewModel
    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        dashboardViewModel: DashboardOfflineSyncProgressCardViewModel
    ) {
        self.config = config
        self.dashboardViewModel = dashboardViewModel
        setupObserver()
    }

    func dismiss() {
        dashboardViewModel.dismissDidTap.accept(())
    }

    func cardTapped(viewController: WeakViewController) {
        dashboardViewModel.cardDidTap.accept(viewController)
    }

    func makeView() -> OfflineSyncProgressWidgetView {
        OfflineSyncProgressWidgetView(model: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }

    private func setupObserver() {
        dashboardViewModel.$state
            .sink { [weak self] coreState in
                guard let self else { return }

                switch coreState {
                case .hidden:
                    self.state = .empty
                    self.progress = 0
                    self.progressText = ""
                    self.backgroundColor = .backgroundDarkest
                    self.title = nil
                    self.subtitleText = nil

                case .progress(let progressValue, let text):
                    self.state = .data
                    self.progress = progressValue
                    self.progressText = text
                    self.backgroundColor = .backgroundDarkest
                    self.title = String(localized: "Syncing Offline Content", bundle: .student)
                    self.subtitleText = text

                case .error:
                    self.state = .error
                    self.progress = 0
                    self.progressText = ""
                    self.backgroundColor = .backgroundDanger
                    self.title = String(localized: "Offline Content Sync Failed", bundle: .student)
                    self.subtitleText = String(localized: "We couldn't sync your content.\nTry again, or come back later", bundle: .student)
                }
            }
            .store(in: &subscriptions)
    }
}
