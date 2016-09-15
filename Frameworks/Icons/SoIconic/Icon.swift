//
//  Icon.swift
//  Icons
//
//  Created by Derrick Hathaway on 6/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation


public enum Icon: String {
    case calendar
    case courses
    case inbox
    case announcements
    case edit
    case assignment
    case quiz
    case lti
    case discussion
    
    
    /** name of the icon of the form "icon_lined"
     */
    func imageName(filled: Bool) -> String {
        return rawValue + (!filled ? "_line": "")
    }
}