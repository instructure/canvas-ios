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
    case scheduleFailed
}

public struct AssignmentReminderContext {
    let courseId: String
    let assignmentId: String
    let userId: String
    let assignmentName: String
    let dueDate: Date?
}

public protocol AssignmentRemindersInteractor: AnyObject {

    // MARK: - Outputs
    var isRemindersSectionVisible: CurrentValueSubject<Bool, Never> { get }
    var reminders: CurrentValueSubject<[AssignmentReminderItem], Never> { get }
    var newReminderCreationResult: PassthroughSubject<NewReminderResult, Never> { get }

    // MARK: - Inputs
    var contextDidUpdate: CurrentValueSubject<AssignmentReminderContext?, Never> { get }
    var newReminderDidSelect: PassthroughSubject<DateComponents, Never> { get }
    var reminderDidDelete: PassthroughSubject<AssignmentReminderItem, Never> { get }
}

public class AssignmentRemindersInteractorLive: AssignmentRemindersInteractor {
    // MARK: - Outputs
    public let isRemindersSectionVisible = CurrentValueSubject<Bool, Never>(false)
    public let reminders = CurrentValueSubject<[AssignmentReminderItem], Never>([])
    public let newReminderCreationResult = PassthroughSubject<NewReminderResult, Never>()

    // MARK: - Inputs
    public let contextDidUpdate = CurrentValueSubject<AssignmentReminderContext?, Never>(nil)
    public let newReminderDidSelect = PassthroughSubject<DateComponents, Never>()
    public let reminderDidDelete = PassthroughSubject<AssignmentReminderItem, Never>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let notificationManager: NotificationManager
    private let courseId: String
    private let assignmentId: String
    private let userId: String

    public init(courseId: String,
                assignmentId: String,
                userId: String,
                notificationManager: NotificationManager) {
        self.courseId = courseId
        self.assignmentId = assignmentId
        self.userId = userId
        self.notificationManager = notificationManager
        showReminderViewIfDueDateIsInFuture()
        scheduleNotificationOnTimeSelect()
        setupReminderDeletion()
    }

    private func showReminderViewIfDueDateIsInFuture() {
        contextDidUpdate
            .map {
                guard let dueAt = $0?.dueDate else {
                    return false
                }
                return dueAt > Clock.now
            }
            .subscribe(isRemindersSectionVisible)
            .store(in: &subscriptions)
    }

    private func scheduleNotificationOnTimeSelect() {
        newReminderDidSelect
            .flatMap { [contextDidUpdate] beforeTime in
                contextDidUpdate
                    .compactMap { $0 }
                    .filter { $0.dueDate != nil }
                    .map { (beforeTime: beforeTime, context: $0) }
            }
            .flatMap { [notificationManager] (beforeTime, context) in
                notificationManager
                    .requestAuthorization()
                    .mapToValue(true)
                    .replaceError(with: false)
                    .map { (beforeTime: beforeTime, context: context, hasPermission: $0) }
            }
            .flatMap { [notificationManager] (beforeTime, context, hasPermission) in
                if hasPermission {
                    let content = UNNotificationContent.assignmentReminder(context: context, beforeTime: beforeTime)
                    let trigger = UNTimeIntervalNotificationTrigger(assignmentDueDate: context.dueDate!, beforeTime: beforeTime)
                    return notificationManager
                        .schedule(identifier: UUID.string,
                                  content: content,
                                  trigger: trigger)
                        .mapError { _ in AssignmentReminderError.noPermission }
                        .mapToResult()
                } else {
                    return Just(NewReminderResult.failure(.noPermission)).eraseToAnyPublisher()
                }
            }
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

    private func readNotificationsForAssignment() {
        notificationManager.notificationCenter.getPendingNotificationRequests { [courseId, assignmentId, userId] notifications in
            let assignmentNotifications = notifications.filter(courseId: courseId,
                                                               assignmentId: assignmentId,
                                                               userId: userId)
        }
    }
}
