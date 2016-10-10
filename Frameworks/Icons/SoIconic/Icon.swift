//
//  Icon.swift
//  Icons
//
//  Created by Derrick Hathaway on 6/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation


public enum Icon: String {
    case announcement
    case assignment
    case calendar
    case collaboration
    case conference
    case course
    case discussion
    case file
    case grades
    case home
    case link
    case lti
    case module
    case outcome
    case page
    case prerequisite
    case quiz
    case settings
    case syllabus
    case user

    case inbox

    case edit
    case lock
    case empty
    case complete
    
    
    /** name of the icon of the form "icon_lined"
     */
    func imageName(filled: Bool) -> String {
        return rawValue + (!filled ? "_line": "")
    }
}
