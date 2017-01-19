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
import Pathetic

let apiV1 = /?"api"/"v1"
let courses = apiV1/?"courses"
let course = courses/string
let assignments = course/"assignments"
let assignment = assignments/string


let TeachRoutes = [
    
    Route(presentation: .master, path: course) { courseID, session, navigator in
        return try AssignmentsTableViewController(session: session, courseID: courseID, route: navigator.routeAction)
    },
    
    Route(presentation: .detail, path: assignment) { parameters, route, session in
        let (courseID, assignmentID) = parameters
        return UIViewController() // TODO: new assignment detail vc
    }
]
