//
//  AssignmentsTableViewController.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/12/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import AssignmentKit
import TooLegit
import EnrollmentKit
import SoLazy
import ReactiveCocoa
import SoPersistent


class AssignmentsTableViewController: Assignment.TableViewController {
    let route: RouteAction
    
    init(session: Session, courseID: String, route: RouteAction) throws {
        self.route = route
        super.init()
        let dataSource = session.enrollmentsDataSource
        title = dataSource[ContextID(id: courseID, context: .Course)]?.name
        prepare(try Assignment.collectionByDueDate(session, courseID: courseID), refresher: try Assignment.refresher(session, courseID: courseID)) { assignment in
            return AssignmentViewModel(assignment: assignment, session: session)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
    }
    
    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"no storyboard support today... sorry"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let assignment = collection[indexPath]
        
        do {
            try route(self, assignment.htmlURL)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
}