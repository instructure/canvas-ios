
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


let TeachRoutes = [
    
    Route(.Master, path: "/courses/{courseID}") { route, session, parameters in
        guard let courseID = parameters["courseID"] else { return nil }
        return try AssignmentsTableViewController(session: session, courseID: courseID, route: route)
    },
    
    Route(.Detail, path: "/courses/{courseID}/assignments/{assignmentID}") { route, session, parameters in
        guard let courseID = parameters["courseID"],
            assignmentID = parameters["assignmentID"] else { return nil }
        return try AssignmentsPagedViewController(route, session: session, courseID: courseID, assignmentID: assignmentID)
    }
]