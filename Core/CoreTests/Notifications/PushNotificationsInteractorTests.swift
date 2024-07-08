//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import XCTest
@testable import Core
import UserNotifications

class PushNotificationsInteractorTests: CoreTestCase {
    private let deviceToken = Data([123])
    private let loginSession = LoginSession.make()
    private let pushChannelId = "pushChannelId"

    func testSubscribesToPush() {
        // GIVEN
        let postsPushNotificationRequest = expectation(description: "postsPushNotificationRequest")
        api.mock(PostCommunicationChannelRequest(pushToken: deviceToken)) { _ in
            postsPushNotificationRequest.fulfill()
            return (.make(id: ID(rawValue: self.pushChannelId)), nil, nil)
        }

        let getsIfPushChannelDefaultsAreSet = expectation(description: "getsIfPushChannelDefaultsAreSet")
        api.mock(GetNotificationDefaultsFlagRequest()) { _ in
            getsIfPushChannelDefaultsAreSet.fulfill()
            return (nil, nil, nil)
        }

        let getsPushChannelSettings = expectation(description: "getsPushChannelSettings")
        api.mock(GetNotificationPreferencesRequest(channelID: pushChannelId)) { _ in
            getsPushChannelSettings.fulfill()
            return (.init(notification_preferences: []), nil, nil)
        }

        let putsNewPushChannelSettings = expectation(description: "putsNewPushChannelSettings")
        let putPushChannelSettingsRequest = PutNotificationPreferencesRequest(
            channelID: pushChannelId,
            notifications: [],
            frequency: .immediately
        )
        api.mock(putPushChannelSettingsRequest) { _ in
            putsNewPushChannelSettings.fulfill()
            return (.init(notification_preferences: []), nil, nil)
        }

        let putsThatPushChannelDefaultsAreSet = expectation(description: "putsThatPushChannelDefaultsAreSet")
        api.mock(PutNotificationDefaultsFlagRequest()) { _ in
            putsThatPushChannelDefaultsAreSet.fulfill()
            return (nil, nil, nil)
        }

        // WHEN
        pushNotificationsInteractor.userDidLogin(loginSession: loginSession)
        pushNotificationsInteractor.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)

        // THEN
        wait(
            for: [
                postsPushNotificationRequest,
                getsIfPushChannelDefaultsAreSet,
                getsPushChannelSettings,
                putsNewPushChannelSettings,
                putsThatPushChannelDefaultsAreSet
            ],
            timeout: 1
        )
    }

    func testNotSubscribesAgainIfDeviceTokenAndLoginSessionNotChanged() {
        // GIVEN
        let postsPushNotificationRequest = expectation(description: "postsPushNotificationRequest")
        api.mock(PostCommunicationChannelRequest(pushToken: deviceToken)) { _ in
            postsPushNotificationRequest.fulfill()
            return (.make(id: ID(rawValue: self.pushChannelId)), nil, nil)
        }

        // WHEN
        pushNotificationsInteractor.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)
        pushNotificationsInteractor.userDidLogin(loginSession: loginSession)
        pushNotificationsInteractor.userDidLogin(loginSession: loginSession)
        pushNotificationsInteractor.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)

        // THEN
        wait(for: [postsPushNotificationRequest])
    }

    func testUnsubscription() {
        // GIVEN
        api.mock(PostCommunicationChannelRequest(pushToken: deviceToken),
                 value: .make(id: ID(rawValue: pushChannelId)))
        let deletesPushNotificationRequest = expectation(description: "deletesPushNotificationRequest")
        api.mock(DeletePushChannelRequest(pushToken: deviceToken)) { _ in
            deletesPushNotificationRequest.fulfill()
            return (nil, nil, nil)
        }
        pushNotificationsInteractor.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)
        pushNotificationsInteractor.userDidLogin(loginSession: loginSession)

        // WHEN
        pushNotificationsInteractor.unsubscribeFromCanvasPushNotifications()

        // THEN
        wait(for: [deletesPushNotificationRequest])
    }

    func testSubscribesAfterUnsubscription() {
        // GIVEN
        let postsPushNotificationRequest = expectation(description: "postsPushNotificationRequest")
        postsPushNotificationRequest.expectedFulfillmentCount = 2
        api.mock(PostCommunicationChannelRequest(pushToken: deviceToken)) { _ in
            postsPushNotificationRequest.fulfill()
            return (.make(id: ID(rawValue: self.pushChannelId)), nil, nil)
        }
        let deletesPushNotificationRequest = expectation(description: "deletesPushNotificationRequest")
        api.mock(DeletePushChannelRequest(pushToken: deviceToken)) { _ in
            deletesPushNotificationRequest.fulfill()
            return (nil, nil, nil)
        }
        pushNotificationsInteractor.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)
        pushNotificationsInteractor.userDidLogin(loginSession: loginSession)
        pushNotificationsInteractor.unsubscribeFromCanvasPushNotifications()

        // WHEN
        pushNotificationsInteractor.userDidLogin(loginSession: loginSession)

        // THEN
        wait(for: [postsPushNotificationRequest, deletesPushNotificationRequest])
    }

    func testResubscribesWhenDeviceTokenChanges() {
        // GIVEN
        let postsPushNotificationRequest = expectation(description: "postsPushNotificationRequest")
        api.mock(PostCommunicationChannelRequest(pushToken: deviceToken)) { _ in
            postsPushNotificationRequest.fulfill()
            return (.make(id: ID(rawValue: self.pushChannelId)), nil, nil)
        }

        pushNotificationsInteractor.applicationDidRegisterForPushNotifications(deviceToken: deviceToken)
        pushNotificationsInteractor.userDidLogin(loginSession: loginSession)

        let newDeviceToken = Data([32])
        let postsNewPushNotificationRequest = expectation(description: "postsNewPushNotificationRequest")
        api.mock(PostCommunicationChannelRequest(pushToken: newDeviceToken)) { _ in
            postsNewPushNotificationRequest.fulfill()
            return (.make(id: ID(rawValue: self.pushChannelId)), nil, nil)
        }

        // WHEN
        pushNotificationsInteractor.applicationDidRegisterForPushNotifications(deviceToken: newDeviceToken)

        // THEN
        wait(for: [postsPushNotificationRequest, postsNewPushNotificationRequest])
    }
}
