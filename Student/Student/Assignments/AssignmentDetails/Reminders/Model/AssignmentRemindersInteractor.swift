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

public protocol AssignmentRemindersInteractor: AnyObject {
    // MARK: - Outputs
    var isRemindersSectionVisible: CurrentValueSubject<Bool, Never> { get }
    var reminders: CurrentValueSubject<[AssignmentReminderItem], Never> { get }

    // MARK: - Inputs
    var assignmentDidUpdate: PassthroughSubject<Assignment, Never> { get }
    var newReminderDidSelect: PassthroughSubject<DateComponents, Never> { get }
    var reminderDidDelete: PassthroughSubject<AssignmentReminderItem, Never> { get }
}

public class AssignmentRemindersInteractorLive: AssignmentRemindersInteractor {
    // MARK: - Outputs
    public let isRemindersSectionVisible = CurrentValueSubject<Bool, Never>(false)
    public let reminders = CurrentValueSubject<[AssignmentReminderItem], Never>([])

    // MARK: - Inputs
    public let assignmentDidUpdate = PassthroughSubject<Assignment, Never>()
    public let newReminderDidSelect = PassthroughSubject<DateComponents, Never>()
    public let reminderDidDelete = PassthroughSubject<AssignmentReminderItem, Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()

    public init() {
        setupReminderAvailability()
        setupNewReminderHandler()
        setupReminderDeletion()
    }

    private func setupReminderAvailability() {
        assignmentDidUpdate
            .map {
                guard let dueAt = $0.dueAt else {
                    return false
                }
                return dueAt > Clock.now
            }
            .subscribe(isRemindersSectionVisible)
            .store(in: &subscriptions)
    }

    private func setupNewReminderHandler() {
        let formatter = AssignmentReminderTimeFormatter()
        newReminderDidSelect
            .compactMap { formatter.string(from: $0)?.lowercased() }
            .map { AssignmentReminderItem(title: $0) }
            .map { [reminders] in
                reminders.value + [$0]
            }
            .subscribe(reminders)
            .store(in: &subscriptions)
    }

    private func setupReminderDeletion() {
        reminderDidDelete
            .map { [reminders] (deleted) in
                var newList = reminders.value
                newList.removeAll { $0 == deleted }
                return newList
            }
            .subscribe(reminders)
            .store(in: &subscriptions)
    }
}
