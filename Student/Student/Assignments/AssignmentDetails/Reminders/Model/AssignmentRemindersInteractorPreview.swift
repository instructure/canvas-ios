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

#if DEBUG

import Combine
import Foundation

class AssignmentRemindersInteractorPreview: AssignmentRemindersInteractor {
    let newReminderCreationResult = PassthroughSubject<Student.NewReminderResult, Never>()
    let isRemindersSectionVisible = CurrentValueSubject<Bool, Never>(true)
    let reminders = CurrentValueSubject<[AssignmentReminderItem], Never>([])
    let contextDidUpdate = CurrentValueSubject<AssignmentReminderContext?, Never>(nil)
    let newReminderDidSelect = PassthroughSubject<DateComponents, Never>()
    let reminderDidDelete = PassthroughSubject<AssignmentReminderItem, Never>()

    private var subscriptions = Set<AnyCancellable>()

    init() {
        newReminderDidSelect
            .map { [reminders] _ in
                let newReminder = AssignmentReminderItem(title: String("5 minutes before"))
                var reminders = reminders.value
                reminders.append(newReminder)
                return reminders
            }
            .subscribe(reminders)
            .store(in: &subscriptions)

        reminderDidDelete
            .map { [reminders] deleted in
                var reminders = reminders.value
                reminders.removeAll { item in
                    item.id == deleted.id
                }
                return reminders
            }
            .subscribe(reminders)
            .store(in: &subscriptions)
    }

    func deleteAllReminders(userId: String) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }
}

#endif
