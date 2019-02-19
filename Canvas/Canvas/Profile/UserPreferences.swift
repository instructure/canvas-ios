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
    
    enum LandingPage: String {
        case Courses        = "Courses"
        case Calendar       = "Calendar"
        case ToDo           = "To-Do List"
        case Notifications  = "Notifications"
        case Messages       = "Messages"

        /// Note: this must be synchronized with the list in RootViewController()
        var tabIndex: Int {
            switch self {
            case .Courses:          return 0
            case .Calendar:         return 1
            case .ToDo:             return 2
            case .Notifications:    return 3
            case .Messages:         return 4
            }
        }
    }
    
    fileprivate static let LandingPageKey = "landingPageSettings"
    
    static func landingPage(_ userID: String) -> UserPreferences.LandingPage {
        guard let landingPagePreferencesByUser: [String: String] = UserDefaults.standard
            .object(forKey: UserPreferences.LandingPageKey) as? [String: String] else {
                return .Courses
        }
        
        return landingPagePreferencesByUser[userID]
            .flatMap(LandingPage.init)
            ?? .Courses
    }
}


