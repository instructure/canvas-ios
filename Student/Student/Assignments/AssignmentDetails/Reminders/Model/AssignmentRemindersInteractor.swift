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
    private let notificationCenter: UserNotificationCenterProtocol

    public init(notificationCenter: UserNotificationCenterProtocol) {
        self.notificationCenter = notificationCenter
        showReminderViewIfDueDateIsInFuture()
        scheduleNotificationOnTimeSelect()
        setupReminderDeletion()
        updateRemindersListOnNewReminderCreation()
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
            .flatMap { [notificationCenter] (beforeTime, context) in
                notificationCenter
                    .requestAuthorization()
                    .mapToValue(true)
                    .replaceError(with: false)
                    .map { (beforeTime: beforeTime, context: context, hasPermission: $0) }
            }
            .flatMap { [notificationCenter] (beforeTime, context, hasPermission) in
                guard hasPermission else {
                    return Just(NewReminderResult.failure(.noPermission)).eraseToAnyPublisher()
                }
                guard let trigger = UNTimeIntervalNotificationTrigger(assignmentDueDate: context.dueDate!, beforeTime: beforeTime) else {
                    return Just(NewReminderResult.failure(.scheduleFailed)).eraseToAnyPublisher()
                }
                let content = UNNotificationContent.assignmentReminder(context: context, beforeTime: beforeTime)
                let request = UNNotificationRequest(identifier: UUID.string,
                                                    content: content,
                                                    trigger: trigger)
                return notificationCenter
                    .add(request)
                    .mapError { _ in AssignmentReminderError.noPermission }
                    .mapToResult()
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

    private func updateRemindersListOnNewReminderCreation() {
        let reminderCreated = newReminderCreationResult
            .filter { (try? $0.get()) != nil }
            .flatMap { [contextDidUpdate] _ in contextDidUpdate }
            .compactMap { $0 }

        let contextLoaded = contextDidUpdate
            .compactMap { $0 }
            .first()

        Publishers
            .Merge(reminderCreated, contextLoaded)
            .flatMap { [notificationCenter] context in
                notificationCenter
                    .getPendingNotificationRequests()
                    .map { ($0, context) }
            }
            .map { (notifications, context) in
                notifications.filter(courseId: context.courseId,
                                     assignmentId: context.assignmentId,
                                     userId: context.userId)
            }
            .map { notifications in
                notifications.compactMap { AssignmentReminderItem(notification: $0) }
            }
            .subscribe(reminders)
            .store(in: &subscriptions)
    }
}
