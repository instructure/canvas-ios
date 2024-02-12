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

public typealias NewReminderResult = Result<Void, AssignmentReminderError>
public enum AssignmentReminderError: Error, Equatable {
    case noPermission
}

public protocol AssignmentRemindersInteractor: AnyObject {

    // MARK: - Outputs
    var isRemindersSectionVisible: CurrentValueSubject<Bool, Never> { get }
    var reminders: CurrentValueSubject<[AssignmentReminderItem], Never> { get }
    var newReminderCreationResult: PassthroughSubject<NewReminderResult, Never> { get }

    // MARK: - Inputs
    var assignmentDidUpdate: PassthroughSubject<Assignment, Never> { get }
    var newReminderDidSelect: PassthroughSubject<DateComponents, Never> { get }
    var reminderDidDelete: PassthroughSubject<AssignmentReminderItem, Never> { get }
}

public class AssignmentRemindersInteractorLive: AssignmentRemindersInteractor {
    // MARK: - Outputs
    public let isRemindersSectionVisible = CurrentValueSubject<Bool, Never>(false)
    public let reminders = CurrentValueSubject<[AssignmentReminderItem], Never>([])
    public let newReminderCreationResult = PassthroughSubject<NewReminderResult, Never>()

    // MARK: - Inputs
    public let assignmentDidUpdate = PassthroughSubject<Assignment, Never>()
    public let newReminderDidSelect = PassthroughSubject<DateComponents, Never>()
    public let reminderDidDelete = PassthroughSubject<AssignmentReminderItem, Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let notificationManager: NotificationManager

    public init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
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
        newReminderDidSelect
            .requestNotificationPermission(notificationManager)
            .scheduleNotification(notificationManager)
            .subscribe(newReminderCreationResult)
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

private extension Publisher where Output == DateComponents,
                                  Failure == Never {

    func requestNotificationPermission(
        _ notificationManager: NotificationManager
    ) -> AnyPublisher<(hasPermission: Bool, time: DateComponents), Never> {
        flatMap { time in
            notificationManager
                .requestAuthorization()
                .mapToValue(true)
                .replaceError(with: false)
                .map { (hasPermission: $0, time: time) }
        }
        .eraseToAnyPublisher()
    }
}

private extension Publisher where Output == (hasPermission: Bool, time: DateComponents),
                                  Failure == Never {

    func scheduleNotification(
        _ notificationManager: NotificationManager
    ) -> AnyPublisher<NewReminderResult, Never> {
        flatMap {
            if $0.hasPermission {
                // Call noti manager
                return Just(NewReminderResult.success(()))
            } else {
                return Just(NewReminderResult.failure(.noPermission))
            }
        }
        .eraseToAnyPublisher()
    }
}
