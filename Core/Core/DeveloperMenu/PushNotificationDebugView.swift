//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import SwiftUI
import UserNotifications

public struct PushNotificationDebugView: View {
    @Environment(\.appEnvironment.router) var router
    @Environment(\.viewController) var controller

    private let notifications: [String]

    public init() {
        let array = UserDefaults.standard.array(forKey: "PushNotificationsStorageKey") ?? []
        notifications = array.compactMap { element in
            if let data = try? JSONSerialization.data(withJSONObject: element, options: [.prettyPrinted, .withoutEscapingSlashes]) {
                return String(data: data, encoding: String.Encoding.utf8)
            } else { return nil }
        }
    }

    public var body: some View {
        List {
            ForEach(notifications, id: \.self) { notification in
                Text(notification)
            }
        }
        .listStyle(.plain)
        .background(Color.backgroundLightest)
        .navigationTitle("Push Notifications")
    }
}
