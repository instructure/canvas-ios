//
//  TeachRoutes.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/12/16.
//  Copyright © 2016 Instructure. All rights reserved.
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