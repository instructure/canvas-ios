//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    case discussion
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
