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
import SwiftUI

class CourseSyncProgressViewModel: ObservableObject {
    enum State {
        case loading
        case error
        case data
        case dataWithError
    }

    // MARK: - Output

    @Published public private(set) var state = State.loading
    @Published public private(set) var cells: [Cell] = []
    @Published public private(set) var showRetryButton = false
    @Published public var isShowingCancelDialog = false

    public let labels = (
        noCourses: (
            title: NSLocalizedString("No Courses", comment: ""),
            message: NSLocalizedString("Your courses will be listed here, and then you can make them available for offline usage.", comment: "")
        ),
        noItems: (
            title: NSLocalizedString("No Course Content", comment: ""),
            message: NSLocalizedString("The course content will be listed here, and then you can make them available for offline usage.", comment: "")
        ),
        error: (
            title: NSLocalizedString("Something went wrong", comment: ""),
            message: NSLocalizedString("There was an unexpected error.", comment: "")
        )
    )

    public let confirmAlert = ConfirmationAlertViewModel(
        title: NSLocalizedString("Cancel Sync?", comment: ""),
        message: NSLocalizedString(
           """
           It will stop offline content sync. You can do it again later.
           """, comment: ""),
        cancelButtonTitle: NSLocalizedString("No", comment: ""),
        confirmButtonTitle: NSLocalizedString("Yes", comment: ""),
        isDestructive: false
    )

    // MARK: - Input

    public let cancelButtonDidTap = PassthroughRelay<Void>()
    public let viewOnAppear = CurrentValueRelay<WeakViewController?>(nil)
    public let dismissButtonDidTap = PassthroughRelay<WeakViewController>()
    public let retryButtonDidTap = PassthroughRelay<Void>()

    // MARK: - Private

    private let interactor: CourseSyncProgressInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router

    init(interactor: CourseSyncProgressInteractor, router: Router) {
        self.interactor = interactor
        self.router = router
        updateState(interactor)
        handleCancelButtonTap()
        handleCancelConfirmButtonTap(interactor)
        handleDismissButtonTap(interactor)
        handleRetryButtonTap(interactor, router: router)
    }

    private func handleCancelButtonTap() {
        cancelButtonDidTap
            .sink { [unowned self] _ in
                isShowingCancelDialog = true
            }
            .store(in: &subscriptions)
    }

    private func handleCancelConfirmButtonTap(_ interactor: CourseSyncProgressInteractor) {
        unowned let unownedSelf = self

        cancelButtonDidTap
            .flatMap { unownedSelf.confirmAlert.userConfirmation() }
            .flatMap { unownedSelf.viewOnAppear.first().compactMap { $0 }}
            .sink { viewController in
                interactor.cancelSync()
                unownedSelf.router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }

    private func handleDismissButtonTap(_: CourseSyncProgressInteractor) {
        dismissButtonDidTap
            .sink { [unowned router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }

    private func handleRetryButtonTap(_ interactor: CourseSyncProgressInteractor, router: Router) {
        retryButtonDidTap
            .sink { _ in
                interactor.retrySync()
            }
            .store(in: &subscriptions)
    }

    private func updateState(_ interactor: CourseSyncProgressInteractor) {
        Publishers.CombineLatest(
            interactor.observeDownloadProgress().setFailureType(to: Error.self),
            interactor.observeEntries()
        )
        .map { ($0.0, $0.1.makeSyncProgressViewModelItems(interactor: interactor)) }
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { [unowned self] downloadProgress, entryProgressList in
            if entryProgressList.count > 0 {
                state = .data

                if downloadProgress.firstItem?.isFinished ?? false, downloadProgress.firstItem?.error != nil {
                    state = .dataWithError
                }
            }
        }, receiveCompletion: { [unowned self] result in
            if case .failure = result {
                state = .error
            }
        })
        .map { $0.1 }
        .replaceError(with: [])
        .assign(to: &$cells)
    }
}
