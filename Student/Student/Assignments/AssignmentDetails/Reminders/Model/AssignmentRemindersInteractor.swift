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
import Foundation
import UserNotifications

public typealias NewReminderResult = Result<Void, AssignmentReminderError>
public enum AssignmentReminderError: Error, Equatable {
    case noPermission
    case scheduleFailed
    case reminderInPast
    case duplicate
    case application
}

public struct AssignmentReminderContext {
    let courseId: String
    let assignmentId: String
    let userId: String
    let assignmentName: String
    let dueDate: Date
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
    func deleteAllReminders(userId: String) -> AnyPublisher<Void, Never>
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
        updateRemindersOnNewReminderAndFirstLoad()
    }

    public func deleteAllReminders(userId: String) -> AnyPublisher<Void, Never> {
        notificationCenter
            .getPendingNotificationRequests()
            .map { $0.filter(userId: userId) }
            .map { notifications in
                notifications.map { $0.identifier }
            }
            .flatMap { [notificationCenter] in
                notificationCenter.removePendingNotificationRequests(withIdentifiers: $0)
            }
            .eraseToAnyPublisher()
    }

    private func showReminderViewIfDueDateIsInFuture() {
        contextDidUpdate
            .map {
                guard let dueAt = $0?.dueDate else {
                    return false
                }
                return dueAt > Clock.now
            }
            .sink { [weak isRemindersSectionVisible] in
                isRemindersSectionVisible?.send($0)
            }
            .store(in: &subscriptions)
    }

    private func scheduleNotificationOnTimeSelect() {
        typealias NotificationData = (beforeTime: DateComponents,
                                      context: AssignmentReminderContext,
                                      trigger: UNCalendarNotificationTrigger)

        let waitForAssignmentData: (DateComponents) -> AnyPublisher<(DateComponents, AssignmentReminderContext), Never> = { [contextDidUpdate] beforeTime in
            contextDidUpdate
                .compactMap { $0 }
                .map { (beforeTime: beforeTime, context: $0) }
                .eraseToAnyPublisher()
        }
        let askForPermission: ((DateComponents, AssignmentReminderContext)) -> AnyPublisher<(DateComponents, AssignmentReminderContext), Error> = { [notificationCenter] data in
            notificationCenter
                .requestAuthorization()
                .map { data }
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        let createNotificationTrigger: ((DateComponents, AssignmentReminderContext)) -> AnyPublisher<NotificationData, Error> = {
            let trigger: UNCalendarNotificationTrigger
            do {
                try trigger = UNCalendarNotificationTrigger(assignmentDueDate: $0.1.dueDate,
                                                            beforeTime: $0.0)
            } catch {
                let error = (error as? AssignmentReminderError) ?? .scheduleFailed
                return Fail(outputType: NotificationData.self, failure: error)
                        .eraseToAnyPublisher()
            }

            return Just(($0.0, $0.1, trigger)).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let checkDuplicateReminders: (NotificationData) -> AnyPublisher<NotificationData, Error> = { [notificationCenter] data in
            notificationCenter
                .getPendingNotificationRequests(for: data.context)
                .flatMap { notifications -> AnyPublisher<NotificationData, Error> in
                    if notifications.hasTriggerForTheSameTime(timeTrigger: data.trigger) {
                        return Fail(outputType: NotificationData.self,
                                    failure: AssignmentReminderError.duplicate as Error)
                        .eraseToAnyPublisher()
                    } else {
                        return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()

        }
        let scheduleNotification: (NotificationData) -> AnyPublisher<Result<Void, AssignmentReminderError>, Never> = { [notificationCenter] in
            let content = UNNotificationContent.assignmentReminder(context: $0.context, beforeTime: $0.beforeTime)
            let request = UNNotificationRequest(identifier: UUID.string,
                                                content: content,
                                                trigger: $0.trigger)
            return notificationCenter
                .add(request)
                .mapError { _ in AssignmentReminderError.scheduleFailed }
                .mapToResult()
                .eraseToAnyPublisher()
        }
        let unifyErrors: (Error) -> AnyPublisher<NewReminderResult, Never> = {
            let convertedError: AssignmentReminderError

            switch $0 {
            case NotificationCenterError.noPermission: convertedError = .noPermission
            case let error as AssignmentReminderError: convertedError = error
            default: convertedError = .scheduleFailed
            }

            return Just(NewReminderResult.failure(convertedError)).eraseToAnyPublisher()
        }

        newReminderDidSelect
            .flatMap { waitForAssignmentData($0) }
            .flatMap { askForPermission($0) }
            .flatMap { createNotificationTrigger($0) }
            .flatMap { checkDuplicateReminders($0) }
            .flatMap { scheduleNotification($0) }
            .catch { unifyErrors($0) }
            .sink(receiveCompletion: { [weak self] _ in
                // On error the stream will complete, so we re-create it to process the next selection action
                self?.scheduleNotificationOnTimeSelect()
            }, receiveValue: { [newReminderCreationResult] in
                newReminderCreationResult.send($0)
            })
            .store(in: &subscriptions)
    }

    private func setupReminderDeletion() {
        reminderDidDelete
            .flatMap { [notificationCenter] reminder in
                notificationCenter
                    .removePendingNotificationRequests(withIdentifiers: [reminder.id])
                    .map { reminder }
            }
            .map { [reminders] (deleted) in
                var newList = reminders.value
                newList.removeAll { $0 == deleted }
                return newList
            }
            .sink { [weak reminders] in
                reminders?.send($0)
            }
            .store(in: &subscriptions)
    }

    private func updateRemindersOnNewReminderAndFirstLoad() {
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
                    .getPendingNotificationRequests(for: context)
                    .map { $0.sorted() }
                    .map { notifications in
                        notifications.compactMap { AssignmentReminderItem(notification: $0) }
                    }
            }
            .sink { [weak reminders] in
                reminders?.send($0)
            }
            .store(in: &subscriptions)
    }
}

private extension UserNotificationCenterProtocol {

    func getPendingNotificationRequests(
        for context: AssignmentReminderContext
    ) -> AnyPublisher<[UNNotificationRequest], Never> {
        getPendingNotificationRequests()
            .map {
                $0.filter(courseId: context.courseId,
                          assignmentId: context.assignmentId,
                          userId: context.userId)
            }
            .eraseToAnyPublisher()
    }
}
