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

import Combine
import CombineSchedulers
import Core
import CoreData
@testable import Horizon
import HorizonUI
import SnapshotTesting
import SwiftUI
import TestsFoundation
import XCTest

class NotificationSettingsViewSnapshotTests: HorizonSnapshotTestCase {
    func testNotificationSettingsViewDefault() {
        let viewModel = createMockNotificationSettingsViewModel(
            isOSNotificationEnabled: true,
            isPushConfigured: true
        )
        viewModel.viewState = .data
        let view = NotificationSettingsView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "notification-settings-default"
        )
    }

    func testNotificationSettingsViewLoading() {
        let viewModel = createMockNotificationSettingsViewModel(
            isOSNotificationEnabled: true,
            isPushConfigured: true
        )
        viewModel.viewState = .loading
        let view = NotificationSettingsView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "notification-settings-loading"
        )
    }

    func testNotificationSettingsViewPushDisabled() {
        let viewModel = createMockNotificationSettingsViewModel(
            isOSNotificationEnabled: false,
            isPushConfigured: true
        )
        viewModel.viewState = .data
        let view = NotificationSettingsView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "notification-settings-push-disabled"
        )
    }

    func testNotificationSettingsViewNoPushConfigured() {
        let viewModel = createMockNotificationSettingsViewModel(
            isOSNotificationEnabled: true,
            isPushConfigured: false
        )
        viewModel.viewState = .data
        let view = NotificationSettingsView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "notification-settings-no-push-configured"
        )
    }

    private func createMockNotificationSettingsViewModel(
        isOSNotificationEnabled: Bool,
        isPushConfigured: Bool
    ) -> NotificationSettingsViewModel {
        let mockInteractor = MockNotificationSettingsInteractor(isPushConfigured: isPushConfigured, context: databaseClient)
        let mockRouter = MockRouter()

        let viewModel = NotificationSettingsViewModel(
            notificationSettingsInteractor: mockInteractor,
            router: mockRouter,
            scheduler: .immediate
        )
        viewModel.isOSNotificationEnabled = isOSNotificationEnabled

        return viewModel
    }
}

private class MockNotificationSettingsInteractor: NotificationSettingsInteractor {
    let isPushConfigured: Bool
    let context: NSManagedObjectContext

    init(isPushConfigured: Bool, context: NSManagedObjectContext) {
        self.isPushConfigured = isPushConfigured
        self.context = context
    }

    func getNotificationPreferences() -> AnyPublisher<[NotificationPreference], Error> {
        var preferences: [NotificationPreference] = []

        let emailCategories: [NotificationPreference.AssociatedCategories] = [.announcement, .due_date, .grading]
        let pushCategories: [NotificationPreference.AssociatedCategories] = isPushConfigured ? [.announcement, .due_date, .grading] : []

        for category in emailCategories {
            if let pref = NotificationPreference.make(context: context, category: category, frequency: .immediate, type: .email) {
                preferences.append(pref)
            }
        }

        for category in pushCategories {
            if let pref = NotificationPreference.make(context: context, category: category, frequency: .immediate, type: .push) {
                preferences.append(pref)
            }
        }

        return Just(preferences)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func isOSNotificationEnabled() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func updateNotificationPreferences(
        type _: NotificationChannel.ChannelType,
        visibleCategory _: NotificationPreference.VisibleCategories,
        currentPreferences _: [NotificationPreference],
        isOn _: Bool
    ) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private class MockRouter: Router {
    init() {
        super.init(routes: [])
    }
}

extension NotificationPreference {
    fileprivate static func make(
        context: NSManagedObjectContext,
        category: AssociatedCategories,
        frequency: Frequency,
        type: NotificationChannel.ChannelType
    ) -> NotificationPreference? {
        guard let notificationCategory = NSEntityDescription.insertNewObject(
            forEntityName: "NotificationCategory",
            into: context
        ) as? NotificationCategory else {
            return nil
        }
        notificationCategory.category = category.rawValue
        notificationCategory.channelID = "channel-1"
        notificationCategory.frequency = frequency == .immediate ? .immediately : .never
        notificationCategory.notifications = ["notif-1"]

        return NotificationPreference(from: notificationCategory, type: type)
    }
}
