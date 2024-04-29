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

import Foundation
import Core

public class SiriShortcutManager: NSObject {
    enum ShortcutType: String {
        case grades = "com.instructure.siri.shortcut.getgrades"

        func title(userInfo: [String: Any]) -> String {
            switch self {
            case ShortcutType.grades:
                guard let name = userInfo["name"] as? String else { return "" }
                let title = String(localized: "Get Grades for", bundle: .canvas)
                return "\(title) \(name)"
            }
        }
    }

    @objc
    public static func donateSiriShortcut(_ userInfo: [String: Any]) {
        guard let identifier = userInfo["identifier"] as? String,
              let shortcutType = ShortcutType(rawValue: identifier),
              let _ = userInfo["name"] as? String else { return }

        let activity = NSUserActivity(activityType: identifier)
        activity.userInfo = userInfo
        activity.title = shortcutType.title(userInfo: userInfo)
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: identifier)

        if let window = AppEnvironment.shared.window {
            if let vc = window.rootViewController?.topMostViewController() {
                vc.userActivity = activity
                activity.becomeCurrent()
            }
        }
    }
}
