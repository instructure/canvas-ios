//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//



import UIKit
import Foundation
import CanvasCore
import CanvasKeymaster
import UserNotifications

extension AppDelegate {
    func didRegisterForRemoteNotifications(_ deviceToken: Data) {
        if let client = CanvasKeymaster.the().currentClient, let baseURL = client.baseURL, let user = client.currentUser {
            let sessionUser = SessionUser(id: user.id, name: user.name, loginID: user.loginID, sortableName: user.sortableName, email: user.email, avatarURL: user.avatarURL)
            var masqueradeID: String?
            if let actAsUserID = client.actAsUserID, actAsUserID.count > 0 {
                masqueradeID = client.actAsUserID
            }
            let session = Session(baseURL: baseURL, user: sessionUser, token: client.accessToken, masqueradeAsUserID: masqueradeID)
            let controller = NotificationKitController(session: session)
            controller.registerPushNotificationTokenWithPushService(deviceToken, registrationCompletion: { [weak self] result in
                switch result {
                case .success():
                    break
                case .error(let error):
                    ErrorReporter.reportError(error.addingInfo(), from: self?.window?.rootViewController)
                }
            })
        }
    }
}
