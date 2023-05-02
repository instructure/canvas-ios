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

    @Published public private(set) var state = State.loading
    @Published public private(set) var items: [Item] = []
    @Published public private(set) var syncButtonDisabled = true
    @Published public private(set) var leftNavBarTitle = ""
    @Published public private(set) var leftNavBarButtonVisible = false
    @Published public private(set) var selectedItemCount = ""
    @Published public var isShowingConfirmationDialog = false
    @Published public private(set) var confirmDialog = ConfirmationAlertViewModel(title: NSLocalizedString("Sync Offline Content?", comment: ""),
                                                                                  message: "", // Updated when selected item count changes
                                                                                  cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
                                                                                  confirmButtonTitle: NSLocalizedString("Sync", comment: ""),
                                                                                  isDestructive: false)

    public let syncButtonDidTap = PassthroughRelay<WeakViewController>()
    public let leftNavBarButtonDidTap = PassthroughRelay<Void>()

    private let interactor: CourseSyncSelectorInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: CourseSyncSelectorInteractor) {
        self.interactor = interactor

        interactor
            .getCourseSyncEntries()
            .map { $0.makeViewModelItems(interactor: interactor) }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.state = .data
                self?.leftNavBarButtonVisible = true
            }, receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.state = .error
                }
            })
            .replaceError(with: [])
            .assign(to: &$items)

        interactor
            .observeSelectedCount()
            .map { $0 == 0 }
            .assign(to: &$syncButtonDisabled)

        interactor
            .observeSelectedCount()
            .map {
                let format = NSLocalizedString("%d Selected", bundle: .core, comment: "3 Selected")
                return String.localizedStringWithFormat(format, $0)
            }
            .assign(to: &$selectedItemCount)

        interactor
            .observeSelectedCount()
            .map { [unowned self] itemCount in
                let format = NSLocalizedString("There are %d items selected for offline availability. The selected content will be downloaded to the device.", bundle: .core, comment: "")
                let message = String.localizedStringWithFormat(format, itemCount)

                var confirmDialog = confirmDialog
                confirmDialog.message = message
                return confirmDialog
            }
            .assign(to: &$confirmDialog)

        interactor
            .observeIsEverythingSelected()
            .map { $0 ? NSLocalizedString("Deselect All", comment: "")
                      : NSLocalizedString("Select All", comment: "") }
            .assign(to: &$leftNavBarTitle)

        leftNavBarButtonDidTap
            .flatMap { interactor.observeIsEverythingSelected().first() }
            .toggle()
            .sink { interactor.toggleAllCoursesSelection(isSelected: $0) }
            .store(in: &subscriptions)

        syncButtonDidTap
            .handleEvents(receiveOutput: { [unowned self] _ in
                isShowingConfirmationDialog = true
            })
            .flatMap { [unowned self] view in
                confirmDialog.confirmDidTap.map { view }
            }
            .flatMap { view in
                interactor.getSelectedCourseEntries()
                    .handleEvents(receiveOutput: { _ in
                        // TODO: Start download, go to dashboard
                        AppEnvironment.shared.router.dismiss(view)
                    })
            }
            .sink()
            .store(in: &subscriptions)
    }
}
