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

import Foundation
import UIKit

enum UserPreferences {
    enum LandingPage: String, CaseIterable {
        // Note: this order must be synchronized with the list in RootViewController()
        case dashboard     = "Courses"
        case calendar      = "Calendar"
        case todo          = "To-Do List"
        case notifications = "Notifications"
        case inbox         = "Messages"

        var tabIndex: Int {
            return LandingPage.allCases.firstIndex(of: self) ?? 0
        }
        
        var description: String {
            switch self {
            case .dashboard:
                return NSLocalizedString("Dashboard", comment: "")
            case .calendar:
                return NSLocalizedString("Calendar", comment: "")
            case .todo:
                return NSLocalizedString("To Do", comment: "")
            case .notifications:
                return NSLocalizedString("Notifications", comment: "")
            case .inbox:
                return NSLocalizedString("Inbox", comment: "")
            }
        }
    }
    
    private static let landingPageKey = "landingPageSettings"
    private static var landingPageDict: [String: String] {
        return UserDefaults.standard.object(forKey: landingPageKey) as? [String: String] ?? [:]
    }
    
    static func landingPage(_ userID: String) -> UserPreferences.LandingPage {
        guard let raw = landingPageDict[userID], let page = LandingPage(rawValue: raw) else {
            return .dashboard
        }
        return page
    }
    
    static func setLandingPage(_ userID: String, page: LandingPage) {
        var dict = landingPageDict
        dict[userID] = page.rawValue
        UserDefaults.standard.set(dict, forKey: landingPageKey)
    }
}


