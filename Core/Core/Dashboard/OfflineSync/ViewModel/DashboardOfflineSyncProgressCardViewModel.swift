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
import CombineExt
import CombineSchedulers

class DashboardOfflineSyncProgressCardViewModel: ObservableObject {
    @Published public private(set) var progress: Float = 0
    @Published public private(set) var isVisible = false
    @Published public private(set) var subtitle = ""

    public let dismissDidTap = PassthroughRelay<Void>()
    public let cardDidTap = PassthroughRelay<WeakViewController>()

    private let interactor: CourseSyncProgressObserverInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: CourseSyncProgressObserverInteractor,
                router: Router,
                scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler

        setupProgressUpdates()
        setupAutoAppearanceOnSyncStart()
        setupAutoDismissUponCompletion()
        setupSubtitleCounterUpdates()
        handleDismissTap()
        handleCardTap()
    }

    private func setupSubtitleCounterUpdates() {
        interactor
            .observeStateProgress()
            .compactMap { $0.allItems }
            .map { $0.ignoreContainerSelections() }
            .map {
                let format = NSLocalizedString("d_items_syncing", comment: "")
                return String.localizedStringWithFormat(format, $0.count) }
            .receive(on: scheduler)
            .assign(to: &$subtitle)
    }

    private func setupProgressUpdates() {
        interactor
            .observeDownloadProgress()
            .map { $0.firstItem?.progress ?? 0 }
            .receive(on: scheduler)
            .assign(to: &$progress)
    }

    private func setupAutoDismissUponCompletion() {
        interactor
            .observeDownloadProgress()
            .map { $0.firstItem?.progress ?? 0 }
            .filter { $0 >= 1 }
            .mapToValue(false)
            .delay(for: .seconds(1), scheduler: scheduler)
            .assign(to: &$isVisible)
    }

    private func setupAutoAppearanceOnSyncStart() {
        NotificationCenter
            .default
            .publisher(for: .OfflineSyncTriggered)
            .mapToValue(true)
            .assign(to: &$isVisible)
    }

    private func handleDismissTap() {
        dismissDidTap
            .map { false }
            .assign(to: &$isVisible)
    }

    private func handleCardTap() {
        cardDidTap
            .sink { [router] viewController in
                router.route(to: "/offline/progress",
                             from: viewController,
                             options: .modal(isDismissable: false, embedInNav: true))
            }
            .store(in: &subscriptions)
    }
}

private extension Array where Element == CourseSyncStateProgress {

    /// Courses and file tabs are not syncable items so we should'n count them.
    func ignoreContainerSelections() -> Self {
        filter { entry in
            switch entry.selection {
            case .course: return false
            case .tab(_, let tabID) where tabID.contains("/tabs/files"): return false
            default: return true
            }
        }
    }
}
