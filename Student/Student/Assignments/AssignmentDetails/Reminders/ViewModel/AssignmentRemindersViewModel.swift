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
import CombineSchedulers
import UIKit

public class AssignmentRemindersViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var reminders: [AssignmentReminderItem] = []
    @Published public private(set) var isReminderSectionVisible = false
    @Published public var showingDeleteConfirmDialog = false
    public let confirmAlert = ConfirmationAlertViewModel(
        title: String(localized: "Delete Reminder", bundle: .student),
        message: String(localized:
           """
           Are you sure you would like to delete this reminder?
           """, bundle: .student),
        cancelButtonTitle: String(localized: "No", bundle: .student),
        confirmButtonTitle: String(localized: "Yes", bundle: .student),
        isDestructive: true
    )

    let interactor: AssignmentRemindersInteractor

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    private weak var newReminderView: UIViewController?
    private let scheduler: AnySchedulerOf<DispatchQueue>

    public init(
        interactor: AssignmentRemindersInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler
        setupInteractorBindings()

        dismissTimePickerAfterNewReminderCreation()
        showErrorAlertOnNewReminderCreationFailure()
    }

    public func newReminderDidTap(view: UIViewController) {
        let picker = AssignmentRemindersAssembly.makeDatePickerView(selectedTimeInterval: interactor.newReminderDidSelect)
        newReminderView = picker
        router.show(picker, from: view, options: .modal(isDismissable: false, embedInNav: true))
    }

    public func reminderDeleteDidTap(_ reminder: AssignmentReminderItem) {
        showingDeleteConfirmDialog = true

        confirmAlert
            .userConfirmation()
            .sink { [weak interactor] in
                // We can't use subscribe because userConfirmation() finishes and
                // the stream would finish the publisher in the interactor as well
                UIAccessibility.announce(String(localized: "Reminder Deleted", bundle: .student))
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
            .receive(on: scheduler)
            .assign(to: &$reminders)
    }

    private func dismissTimePickerAfterNewReminderCreation() {
        interactor
            .newReminderCreationResult
            .compactMap { try? $0.get() }
            .receive(on: scheduler)
            .sink { [weak self, router] _ in
                if let view = self?.newReminderView {
                    router.dismiss(view)
                }
            }
            .store(in: &subscriptions)
    }

    private func showErrorAlertOnNewReminderCreationFailure() {
        interactor
            .newReminderCreationResult
            .compactMap { $0.error }
            .receive(on: scheduler)
            .sink { [weak self] in
                if $0 == .noPermission {
                    self?.newReminderView?.showPermissionError(.notifications)
                } else {
                    let message: String

                    switch $0 {
                    case .reminderInPast:
                        message = String(localized: "Please choose a future time for your reminder!", bundle: .student)
                    case .duplicate:
                        message = String(localized: "You have already set a reminder for this time.", bundle: .student)
                    case .application, .scheduleFailed, .noPermission:
                        message = String(localized: "An unknown error occurred.", bundle: .student)
                    }

                    let alert = UIAlertController(title: String(localized: "Reminder Creation Failed", bundle: .student),
                                                  message: message,
                                                  preferredStyle: .alert)
                    alert.addAction(.init(title: String(localized: "OK", bundle: .student), style: .default))

                    if let self, let reminderView = self.newReminderView {
                        self.router.show(alert, from: reminderView)
                    }
                }
            }
            .store(in: &subscriptions)
    }
}
