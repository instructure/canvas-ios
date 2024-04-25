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

class CourseSyncSelectorViewModel: ObservableObject {
    enum State {
        case loading
        case data
        case error
    }

    // MARK: - Output

    @Published public private(set) var state = State.loading
    @Published public private(set) var cells: [Cell] = []
    @Published public private(set) var navBarSubtitle = ""
    @Published public private(set) var syncButtonDisabled = true
    @Published public private(set) var leftNavBarTitle = ""
    @Published public private(set) var leftNavBarButtonVisible = false
    @Published public var isShowingConfirmationDialog = false

    public let confirmAlert = ConfirmationAlertViewModel(
        title: String(localized: "Sync Offline Content?", bundle: .core),
        message: "", // Updated when selected item count changes
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Sync", bundle: .core),
        isDestructive: false
    )

    public let labels = (
        noCourses: (
            title: String(localized: "No Courses", bundle: .core),
            message: String(localized: "Your courses will be listed here, and then you can make them available for offline usage.", bundle: .core)
        ),
        noItems: (
            title: String(localized: "No Course Content", bundle: .core),
            message: String(localized: "The course content will be listed here, and then you can make them available for offline usage.", bundle: .core)
        ),
        error: (
            title: String(localized: "Something went wrong", bundle: .core),
            message: String(localized: "There was an unexpected error.", bundle: .core)
        )
    )

    // MARK: - Input

    public let syncButtonDidTap = PassthroughRelay<WeakViewController>()
    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let leftNavBarButtonDidTap = PassthroughRelay<Void>()

    // MARK: - Private

    private let selectorInteractor: CourseSyncSelectorInteractor
    private let syncInteractor: CourseSyncInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router

    init(
        selectorInteractor: CourseSyncSelectorInteractor,
        syncInteractor: CourseSyncInteractor,
        router: Router
    ) {
        self.selectorInteractor = selectorInteractor
        self.syncInteractor = syncInteractor
        self.router = router

        updateState(selectorInteractor)
        updateSyncButtonState(selectorInteractor)
        updateConfirmationDialogMessage(selectorInteractor)
        updateSelectAllButtonTitle(selectorInteractor)
        updateNavBarSubtitle(selectorInteractor)

        handleCancelButtonTap()
        handleLeftNavBarTap(selectorInteractor)
        handleSyncButtonTap(
            selectorInteractor: selectorInteractor,
            confirmAlert: confirmAlert
        )
    }

    private func handleCancelButtonTap() {
        cancelButtonDidTap
            .sink { [unowned router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }

    private func updateNavBarSubtitle(_ interactor: CourseSyncSelectorInteractor) {
        interactor
            .getCourseName()
            .assign(to: &$navBarSubtitle)
    }

    private func updateSyncButtonState(_ interactor: CourseSyncSelectorInteractor) {
        interactor
            .observeSelectedCount()
            .map { $0 == 0 }
            .assign(to: &$syncButtonDisabled)
    }

    private func updateSelectAllButtonTitle(_ interactor: CourseSyncSelectorInteractor) {
        interactor
            .observeIsEverythingSelected()
            .map { $0
                ? String(localized: "Deselect All", bundle: .core)
                : String(localized: "Select All", bundle: .core)
            }
            .assign(to: &$leftNavBarTitle)
    }

    private func updateConfirmationDialogMessage(_ interactor: CourseSyncSelectorInteractor) {
        interactor
            .observeSelectedSize()
            .map {
                let template = String(localized:
                    "This will sync ~%@ content. It may result in additional charges from your data provider if you are not connected to a Wi-Fi network.", bundle: .core
                )
                return String.localizedStringWithFormat(template, $0.humanReadableFileSize)
            }
            .assign(to: \.message, on: confirmAlert, ownership: .weak)
            .store(in: &subscriptions)
    }

    private func handleLeftNavBarTap(_ interactor: CourseSyncSelectorInteractor) {
        leftNavBarButtonDidTap
            .flatMap { interactor.observeIsEverythingSelected().first() }
            .toggle()
            .sink { interactor.toggleAllCoursesSelection(isSelected: $0) }
            .store(in: &subscriptions)
    }

    private func handleSyncButtonTap(
        selectorInteractor: CourseSyncSelectorInteractor,
        confirmAlert: ConfirmationAlertViewModel
    ) {
        syncButtonDidTap
            .handleEvents(receiveOutput: { [unowned self] _ in
                isShowingConfirmationDialog = true
            })
            .flatMap { view in
                confirmAlert.userConfirmation().map { view }
            }
            .flatMap { [weak self] view in
                self?.state = .loading

                return Publishers.Zip(
                    selectorInteractor.getDeselectedCourseIds()
                        .delay(for: .milliseconds(500), scheduler: RunLoop.main)
                        .receive(on: DispatchQueue.main)
                        .handleEvents(receiveOutput: { entries in
                            NotificationCenter.default.post(name: .OfflineSyncCleanTriggered, object: entries)
                            AppEnvironment.shared.router.dismiss(view)
                        }),
                    selectorInteractor.getSelectedCourseEntries()
                        .delay(for: .milliseconds(500), scheduler: RunLoop.main)
                        .receive(on: DispatchQueue.main)
                        .handleEvents(receiveOutput: { entries in
                            NotificationCenter.default.post(name: .OfflineSyncTriggered, object: entries)
                            AppEnvironment.shared.router.dismiss(view)
                        })
                ).eraseToAnyPublisher()
            }
            .sink()
            .store(in: &subscriptions)
    }

    private func updateState(_ interactor: CourseSyncSelectorInteractor) {
        interactor
            .getCourseSyncEntries()
            .map { $0.makeViewModelItems(interactor: interactor) }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [unowned self] _ in
                state = .data
                leftNavBarButtonVisible = true
            }, receiveCompletion: { [unowned self] result in
                if case .failure = result {
                    state = .error
                }
            })
            .replaceError(with: [])
            .assign(to: &$cells)
    }
}

extension Notification.Name {
    static let OfflineSyncTriggered = Notification.Name(rawValue: "com.instructure.core.notification.OfflineSyncTriggered")
    static let OfflineSyncCleanTriggered = Notification.Name(rawValue: "com.instructure.core.notification.OfflineSyncCleanTriggered")
    static let OfflineSyncCancelled = Notification.Name(rawValue: "com.instructure.core.notification.OfflineSyncCancelled")
    static let OfflineSyncCompleted = Notification.Name(rawValue: "com.instructure.core.notification.OfflineSyncCompleted")
}
