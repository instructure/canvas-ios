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
    @Published public private(set) var items: [Item] = []
    @Published public private(set) var syncButtonDisabled = true
    @Published public private(set) var leftNavBarTitle = ""
    @Published public private(set) var leftNavBarButtonVisible = false
    @Published public var isShowingConfirmationDialog = false
    public let confirmAlert = ConfirmationAlertViewModel(title: NSLocalizedString("Sync Offline Content?", comment: ""),
                                                         message: "", // Updated when selected item count changes
                                                         cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
                                                         confirmButtonTitle: NSLocalizedString("Sync", comment: ""),
                                                         isDestructive: false)

    // MARK: - Input

    public let syncButtonDidTap = PassthroughRelay<WeakViewController>()
    public let leftNavBarButtonDidTap = PassthroughRelay<Void>()

    // MARK: - Private

    private let selectorInteractor: CourseSyncSelectorInteractor
    private let syncInteractor: CourseSyncInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(
        selectorInteractor: CourseSyncSelectorInteractor,
        syncInteractor: CourseSyncInteractor
    ) {
        self.selectorInteractor = selectorInteractor
        self.syncInteractor = syncInteractor

        updateState(selectorInteractor)
        updateSyncButtonState(selectorInteractor)
        updateConfirmationDialogMessage(selectorInteractor)
        updateSelectAllButtonTitle(selectorInteractor)

        handleLeftNavBarTap(selectorInteractor)
        handleSyncButtonTap(
            selectorInteractor: selectorInteractor,
            syncInteractor: syncInteractor,
            confirmAlert: confirmAlert
        )
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
                ? NSLocalizedString("Deselect All", comment: "")
                : NSLocalizedString("Select All", comment: "")
            }
            .assign(to: &$leftNavBarTitle)
    }

    private func updateConfirmationDialogMessage(_ interactor: CourseSyncSelectorInteractor) {
        interactor
            .observeSelectedCount()
            .map { itemCount in
                let format = NSLocalizedString("There are %d items selected for offline availability. The selected content will be downloaded to the device.", bundle: .core, comment: "")
                return String.localizedStringWithFormat(format, itemCount)
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
        syncInteractor: CourseSyncInteractor,
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
                return selectorInteractor.getSelectedCourseEntries()
                    .flatMap { syncInteractor.downloadContent(for: $0) }
                    .handleEvents(receiveCompletion: { _ in
                        // TODO: Start download, go to dashboard
                        self?.state = .data
                        AppEnvironment.shared.router.dismiss(view)
                    })
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
            .assign(to: &$items)
    }
}
