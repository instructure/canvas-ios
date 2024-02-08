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

public class AssignmentRemindersViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var reminders: [AssignmentReminderItem] = []
    @Published public private(set) var isReminderSectionVisible = false
    @Published public var showingDeleteConfirmDialog = false
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
    private let interactor: AssignmentRemindersInteractor

    public init(interactor: AssignmentRemindersInteractor, router: Router) {
        self.interactor = interactor
        self.router = router
        setupInteractorBindings()
    }

    public func newReminderDidTap(view: UIViewController) {
        let picker = AssignmentRemindersAssembly.makeDatePickerView(selectedTimeInterval: interactor.newReminderDidSelect)
        router.show(picker, from: view, options: .modal(isDismissable: false, embedInNav: true))
    }

    public func reminderDeleteDidTap(_ reminder: AssignmentReminderItem) {
        showingDeleteConfirmDialog = true

        confirmAlert
            .userConfirmation()
            .sink { [weak interactor] in
                // We can't use subscribe because userConfirmation() finishes and
                // the stream would finish the publisher in the interactor as well
                UIAccessibility.announce(String(localized: "Reminder Deleted"))
                interactor?.reminderDidDelete.send(reminder)
            }
            .store(in: &subscriptions)
    }

    // MARK: - Private Methods

    private func setupInteractorBindings() {
        interactor
            .isRemindersSectionVisible
            .assign(to: &$isReminderSectionVisible)

        interactor
            .reminders
            .assign(to: &$reminders)
    }
}
