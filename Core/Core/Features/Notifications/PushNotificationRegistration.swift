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

import Foundation

public extension UIApplication {

    func registerForPushNotifications(
        notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()
    ) {
        guard !ProcessInfo.isUITest else { return }

        notificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in performUIUpdate {
            guard granted, error == nil else { return }
            #if !targetEnvironment(simulator) // Can't register on simulator
                self.registerForRemoteNotifications()
            #endif
        } }
    }
}
