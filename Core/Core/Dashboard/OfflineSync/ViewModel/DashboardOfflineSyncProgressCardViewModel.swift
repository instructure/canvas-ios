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
    enum ViewState: Equatable {
        typealias Progress = Float // Ranging from 0 to 1
        typealias ProgressText = String // Text

        case progress(Progress, ProgressText)
        case error
        case hidden

        var isHidden: Bool {
            switch self {
            case .hidden: return true
            default: return false
            }
        }
    }

    @Published public private(set) var state: ViewState = .hidden

    public let dismissDidTap = PassthroughRelay<Void>()
    public let cardDidTap = PassthroughRelay<WeakViewController>()

    private let progressObserverInteractor: CourseSyncProgressObserverInteractor
    private let progressWriterInteractor: CourseSyncProgressWriterInteractor
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    /**
     - parameters:
        - offlineModeInteractor: This is used to determine if the feature flag is turned on. If it's off then
     we don't subscribe to CoreData updates to save some CPU time.
     */
    public init(progressObserverInteractor: CourseSyncProgressObserverInteractor,
                progressWriterInteractor: CourseSyncProgressWriterInteractor,
                offlineModeInteractor: OfflineModeInteractor,
                router: Router,
                scheduler: AnySchedulerOf<DispatchQueue> = .main) {
        self.progressObserverInteractor = progressObserverInteractor
        self.progressWriterInteractor = progressWriterInteractor
        self.router = router
        self.scheduler = scheduler

        guard offlineModeInteractor.isFeatureFlagEnabled() else { return }

        let downloadProgressPublisher = progressObserverInteractor
            .observeDownloadProgress()
            .share()
            .makeConnectable()

        restorePreviousFailedState(downloadProgressPublisher)
        setupAutoAppearanceOnSyncStart(downloadProgressPublisher)
        setupAutoHideOnSyncCancel()
        setupAutoDismissUponCompletion(downloadProgressPublisher)
        handleDismissTap(progressWriterInteractor)
        handleCardTap()

        downloadProgressPublisher
            .connect()
            .store(in: &subscriptions)
    }

    private typealias DownloadProgressPublisher = Publisher<CourseSyncDownloadProgress, Never>

    private func setupAutoAppearanceOnSyncStart(_ downloadProgressPublisher: some DownloadProgressPublisher) {
        NotificationCenter
            .default
            .publisher(for: .OfflineSyncTriggered)
            .flatMapLatest { [weak self] _ -> AnyPublisher<DashboardOfflineSyncProgressCardViewModel.ViewState, Never> in
                guard let self = self else {
                    return Just(.hidden)
                        .setFailureType(to: Never.self)
                        .eraseToAnyPublisher()
                }
                return setupProgressUpdates(downloadProgressPublisher)
            }
            .receive(on: scheduler)
            .assign(to: &$state)
    }

    private func setupProgressUpdates(
        _ downloadProgressPublisher: some DownloadProgressPublisher
    ) -> AnyPublisher<DashboardOfflineSyncProgressCardViewModel.ViewState, Never> {
        Publishers.CombineLatest(
            progressObserverInteractor.observeStateProgress().map { $0.filterToCourses() },
            downloadProgressPublisher
        )
        .receive(on: scheduler)
        .flatMap { stateProgress, downloadProgress -> AnyPublisher<DashboardOfflineSyncProgressCardViewModel.ViewState, Never> in
            guard stateProgress.count > 0 else {
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

            if downloadProgress.isFinished, downloadProgress.error != nil {
                return Just(.error).eraseToAnyPublisher()
            } else {
                let format = String(localized: "d_courses_syncing", bundle: .core)
                let formattedText = String.localizedStringWithFormat(format, stateProgress.count)
                return Just(.progress(downloadProgress.progress, formattedText)).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    private func restorePreviousFailedState(_ downloadProgressPublisher: some DownloadProgressPublisher) {
        downloadProgressPublisher
            .flatMap { downloadProgress -> AnyPublisher<DashboardOfflineSyncProgressCardViewModel.ViewState, Never> in
                if downloadProgress.isFinished, downloadProgress.error != nil {
                    return Just(.error).eraseToAnyPublisher()
                } else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
            }
            .first()
            .receive(on: scheduler)
            .assign(to: &$state)
    }

    private func setupAutoHideOnSyncCancel() {
        NotificationCenter
            .default
            .publisher(for: .OfflineSyncCancelled)
            .mapToValue(.hidden)
            .receive(on: scheduler)
            .assign(to: &$state)
    }

    private func setupAutoDismissUponCompletion(_ downloadProgressPublisher: some DownloadProgressPublisher) {
        downloadProgressPublisher
            .filter { $0.isFinished && $0.error == nil }
            .mapToValue(.hidden)
            .delay(for: .seconds(1), scheduler: scheduler)
            .receive(on: scheduler)
            .assign(to: &$state)
    }

    private func handleDismissTap(_ interactor: CourseSyncProgressWriterInteractor) {
        dismissDidTap
            .map { _ in interactor.cleanUpPreviousDownloadProgress() } 
            .map { .hidden }
            .assign(to: &$state)
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
