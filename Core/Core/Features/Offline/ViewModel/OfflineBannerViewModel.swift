//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import SwiftUI

public class OfflineBannerViewModel: ObservableObject {
    @Published public var isVisible: Bool
    @Published public var isOffline: Bool

    private weak var offlineBannerContainer: UIViewController?
    private let interactor: OfflineModeInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>

    public init(interactor: OfflineModeInteractor,
                parent: UIViewController,
                scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        let isOffline = interactor.isOfflineModeEnabled()
        self.interactor = interactor
        self.offlineBannerContainer = parent
        self.isVisible = isOffline
        self.isOffline = isOffline
        self.scheduler = scheduler

        let isOfflinePublisher = interactor
            .observeIsOfflineMode()
            .share()
            .makeConnectable()

        showBannerWhenAppGoesOffline(isOfflinePublisher)
        updateDisplayedStateWhenOfflineStateChanges(isOfflinePublisher)
        hideBannerDelayedWhenAppGoesOnline(isOfflinePublisher)

        isOfflinePublisher
            .connect()
            .store(in: &subscriptions)

        updateParentViewSafeAreaForBanner()
    }

    private func showBannerWhenAppGoesOffline(_ isOfflinePublisher: some Publisher<Bool, Never>) {
        isOfflinePublisher
            .filter { $0 }
            .assign(to: &$isVisible)
    }

    private func hideBannerDelayedWhenAppGoesOnline(_ isOfflinePublisher: some Publisher<Bool, Never>) {
        isOfflinePublisher
            .debounce(for: 3, scheduler: scheduler)
            .filter { !$0 }
            .assign(to: &$isVisible)
    }

    private func updateDisplayedStateWhenOfflineStateChanges(_ isOfflinePublisher: some Publisher<Bool, Never>) {
        isOfflinePublisher
            .assign(to: &$isOffline)
    }

    private func updateParentViewSafeAreaForBanner() {
        $isVisible
            .map { UIEdgeInsets(top: 0, left: 0, bottom: $0 ? 32 : 0, right: 0) }
            .sink { [weak self] edges in
                UIView.animate(withDuration: 0.3) {
                    self?.offlineBannerContainer?.additionalSafeAreaInsets = edges
                    self?.offlineBannerContainer?.view.layoutIfNeeded()
                }
            }.store(in: &subscriptions)
    }
}
