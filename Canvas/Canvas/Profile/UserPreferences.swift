//
//  UserPreferences.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 3/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
    
    private static let LandingPageKey = "landingPageSettings"
    
    static func landingPage(userID: String) -> UserPreferences.LandingPage {
        guard let landingPagePreferencesByUser: [String: String] = NSUserDefaults.standardUserDefaults()
            .objectForKey(UserPreferences.LandingPageKey) as? [String: String] else {
                return .Courses
        }
        
        return landingPagePreferencesByUser[userID]
            .flatMap(LandingPage.init)
            ?? .Courses
    }
}


