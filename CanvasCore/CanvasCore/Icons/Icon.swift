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


public enum Icon: String {
    public enum Size {
        case standard
        case small

        var identifier: String {
            switch self {
            case .standard: return ""
            case .small:    return "sm"
            }
        }
    }

    case announcement
    case assignment
    case audio
    case calendar
    case calendarEmpty = "calendar_empty"
    case camera
    case cancel
    case code
    case collaboration
    case conference
    case course
    case courses
    case discussion
    case dropdown
    case email
    case file
    case grades
    case home
    case info
    case link
    case lti
    case module
    case outcome
    case page
    case pdf
    case people
    case prerequisite
    case quiz
    case refresh
    case settings
    case syllabus
    case trash
    case user

    case todo
    case notification

    case edit
    case lock
    case unlock
    case empty
    case complete
    
    case star
    case check
    case expand
    case collapse
    
    case forward
    case backward
    
    /** name of the icon of the form "icon_lined"
     */
    func imageName(_ filled: Bool, size: Size = .standard) -> String {
        var name = rawValue + (!filled ? "_line": "")
        if size != .standard {
            name += "_\(size.identifier)"
        }
        return name
    }
}
