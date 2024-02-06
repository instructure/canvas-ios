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

import Core
import Combine

class AssignmentRemindersViewModel: ObservableObject {
    @Published public private(set) var reminders: [AssignmentReminderItemViewModel] = []
    @Published public var showingDeleteConfirmDialog = false
    @Published public var isReminderSectionVisible = false
    public let confirmAlert = ConfirmationAlertViewModel(
        title: NSLocalizedString("Delete Reminder", comment: ""),
        message: NSLocalizedString(
           """
           Are you sure you would like to delete this reminder?
           """, comment: ""),
        cancelButtonTitle: NSLocalizedString("No", comment: ""),
        confirmButtonTitle: NSLocalizedString("Yes", comment: ""),
        isDestructive: true
    )

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    private let newReminder = PassthroughSubject<DateComponents, Never>()
    private let interactor: AssignmentRemindersInteractor

    public init(interactor: AssignmentRemindersInteractor, router: Router) {
        self.interactor = interactor
        self.router = router
        setupNewReminderHandler()
        setupInteractorBindings()
    }

    public func newReminderDidTap(view: UIViewController) {
        let picker = AssignmentRemindersAssembly.makeDatePickerView(selectedTimeInterval: newReminder)
        router.show(picker, from: view, options: .modal(isDismissable: false, embedInNav: true))
    }

    public func reminderDeleteDidTap(_ reminder: AssignmentReminderItemViewModel) {
        showingDeleteConfirmDialog = true

        confirmAlert
            .userConfirmation()
            .sink { [weak self] in
                guard let self else { return }
                if let index = reminders.firstIndex(of: reminder) {
                    reminders.remove(at: index)
                }
            }
            .store(in: &subscriptions)
    }

    // MARK: - Private Methods

    private func setupNewReminderHandler() {
        let formatter = AssignmentReminderTimeFormatter()
        newReminder
            .compactMap { formatter.string(from: $0)?.lowercased() }
            .map { AssignmentReminderItemViewModel(title: $0) }
            .sink { [weak self] in
                self?.reminders.append($0)
            }
            .store(in: &subscriptions)
    }

    private func setupInteractorBindings() {
        interactor
            .isRemindersSectionVisible
            .assign(to: &$isReminderSectionVisible)
    }
}
