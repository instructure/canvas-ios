//
//  AssignmentsPagedViewController.swift
//  Teach
//
//  Created by Derrick Hathaway on 6/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoPretty
import TooLegit


func AssignmentsPagedViewController(route: RouteAction, session: Session, courseID: String, assignmentID: String) throws -> UIViewController {
    
    let deetsTitle = NSLocalizedString("Details", comment: "button for assignment details on the assignment screen")
    let deets = try AssignmentDetailViewController.new(session, courseID: courseID, assignmentID: assignmentID)
    let deetsPage = ControllerPage(title: deetsTitle, controller: deets)
    
    let subsTitle = NSLocalizedString("Submissions", comment: "button for the list of submissions for the assignment")
    let subs = SubmissionsTableViewController()
    let subsPage = ControllerPage(title: subsTitle, controller: subs)
    
    return PagedViewController(pages: [deetsPage, subsPage])

}