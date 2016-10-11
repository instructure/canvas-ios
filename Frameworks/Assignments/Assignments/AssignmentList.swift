//
//  AssignmentList.swift
//  Assignments
//
//  Created by Derrick Hathaway on 3/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

import AssignmentKit
import SoPersistent
import TooLegit
import ReactiveCocoa
import SoLazy

struct AssignmentViewModel: TableViewCellViewModel {
    let name: String
    let subtitle: String
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: "AssignmentCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "AssignmentCell")
    }
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentCell", forIndexPath: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = subtitle
        return cell
    }
    
    init(assignment: Assignment) {
        name = assignment.name + " \(assignment.gradingPeriodID ?? "none")"
        subtitle = assignment.due.flatMap({ NSDateFormatter.MediumStyleDateTimeFormatter.stringFromDate($0)}) ?? "No Due Date"
    }
}

class AssignmentList: Assignment.TableViewController {
    
    let session: Session
    let courseID: String
    
    init(session: Session, courseID: String) throws {
        self.session = session
        self.courseID = courseID
        super.init()

        let collection = try Assignment.collectionByDueStatus(session, courseID: courseID)
        let refresher = try Assignment.refresher(session, courseID: courseID)
        prepare(collection, refresher: refresher, viewModelFactory: AssignmentViewModel.init)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let assignment = collection[indexPath]
        do {
            let deets = try AssignmentDetailViewController.new(session, courseID: assignment.courseID, assignmentID: assignment.id)
            navigationController?.pushViewController(deets, animated: true)
        } catch let e as NSError {
            error.report(alertUserFrom: self)
        }
    }

}
