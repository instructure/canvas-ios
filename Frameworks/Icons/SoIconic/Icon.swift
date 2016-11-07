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
