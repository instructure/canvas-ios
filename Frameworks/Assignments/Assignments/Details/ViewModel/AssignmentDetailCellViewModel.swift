//
//  AssignmentDetailCellViewModel.swift
//  Assignments
//
//  Created by Nathan Lambson on 3/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import UIKit
import AssignmentKit
import WhizzyWig
import SoPersistent
import SoLazy
import EnrollmentKit
//import CanvasKeymaster
import TooLegit

enum AssignmentDetailCellViewModel: TableViewCellViewModel {
    
    typealias RoutingHandler = ()->Void
    
    case GradeAndSubmission(GradeViewModel, SubmissionStatusViewModel, Bool, Bool, RoutingHandler, RoutingHandler)
    case Title(Assignment)
    case Details(NSURL, String)
    case Padding(Bool)
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch self {
        case .GradeAndSubmission(let gradeViewModel, let submissionViewModel, let showRubric, let showSubmissionHistory, let rubricHandler, let submissionHandler):
            let cell = tableView.dequeueReusableCellWithIdentifier("gradeSubmissionsTableViewCell") as! AssignmentGradeSubmissionTableViewCell
            
            let gradeView = CircularGradeView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
            gradeView.setGrade(gradeViewModel, animated: true)
            gradeView.setupRubricButton(showRubric, buttonPressHandler: rubricHandler)
            
            let submissionStatusView = SubmissionStatusView(frame: CGRect(x: 0, y: 0, width: 160, height: 160), viewModel: submissionViewModel, showSubmissionHistory: showSubmissionHistory)
            submissionStatusView.viewSubmissionDetailsPressedHandler = submissionHandler
            
            cell.leftView.backgroundColor = UIColor.clearColor()
            cell.rightView.backgroundColor = UIColor.clearColor()
            
            cell.leftView.addSubview(gradeView)
            cell.rightView.addSubview(submissionStatusView)
            
            cell.verticalLineWidth.constant = 1/UIScreen.mainScreen().scale
            
            var viewBindingsDict = [String: AnyObject]()
            viewBindingsDict["gradeView"] = gradeView
            
            cell.leftView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[gradeView(==160)]|", options: [], metrics: nil, views: viewBindingsDict))
            cell.leftView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[gradeView(==160)]|", options: [], metrics: nil, views: viewBindingsDict))
            
            return cell
        case .Title(let assignment):
            guard let cell = tableView.dequeueReusableCellWithIdentifier("assignmentInfoCell") else { ❨╯°□°❩╯⌢"expected assignmentInfoCell" }
            allowMultipleLines(cell)
            
            let due = NSLocalizedString("Due: ", comment: "String telling the user that the date is the due date")
            
            let dueDateFormatter = NSDateFormatter()
            dueDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dueDateFormatter.timeStyle = .ShortStyle
            
            let dueDate = (assignment.due != nil) ? due + dueDateFormatter.stringFromDate(assignment.due!) : NSLocalizedString("No Due Date", comment: "Default string for due date title")
            
            cell.textLabel?.text = assignment.name
            cell.detailTextLabel?.text = assignment.lockedForUser == true ? assignment.lockExplanation : dueDate
            
            
            return cell
        case .Details(let baseURL, let deets):
            let cell = WhizzyWigTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "theWhizz")
            cell.whizzyWigView.loadHTMLString(deets, baseURL: baseURL)
            cell.cellSizeUpdated = { [weak tableView] _ in
                tableView?.beginUpdates()
                UIView.setAnimationsEnabled(false)
                tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
                UIView.setAnimationsEnabled(true)
                tableView?.endUpdates()
            }
            cell.selectionStyle = .None
            
            return cell
        case .Padding(let hidden):
            let cell = tableView.dequeueReusableCellWithIdentifier("paddingCell") as! AssignmentPaddingCell
            cell.horizontalLineView.hidden = hidden
            cell.horizontalLineHeight.constant = 1/UIScreen.mainScreen().scale
            return cell
        }
    }
    
    private func allowMultipleLines(tableViewCell:UITableViewCell) {
        tableViewCell.textLabel?.numberOfLines = 0
        tableViewCell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        tableViewCell.detailTextLabel?.numberOfLines = 0
        tableViewCell.detailTextLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
    }
    
    static func detailsForAssignment(session: Session, viewRubricHandler: RoutingHandler, viewSubmissionsHandler: RoutingHandler) -> (assignment: Assignment) -> [AssignmentDetailCellViewModel] {
        return { assignment in
            
            let enrollmentDataSource = session.enrollmentsDataSource[ContextID(id:assignment.courseID, context: .Course)]
            let isTeacher = enrollmentDataSource?.roles?.contains(EnrollmentRoles.Teacher) ?? false
            
            var cells : [AssignmentDetailCellViewModel] = [
                .GradeAndSubmission(GradeViewModel.gradeViewModelForAssignment(assignment), SubmissionStatusViewModel(assignment: assignment), assignment.rubric != nil, !isTeacher && assignment.hasSubmitted && assignment.allowsSubmissions, viewRubricHandler, viewSubmissionsHandler),
                .Padding(false),
                .Title(assignment),
                .Padding(true)
            ]
            
            if assignment.lockedForUser == true && assignment.canView == false {
                cells += [.Padding(true)]
            } else {
                cells += [.Details(session.baseURL, assignment.details)]
            }
            
            return cells
        }
    }
}

// MARK: - Equatable

extension AssignmentDetailCellViewModel: Equatable {}
func ==(lhs: AssignmentDetailCellViewModel, rhs: AssignmentDetailCellViewModel) -> Bool {
    switch (lhs, rhs) {
    case (.GradeAndSubmission(let gradeViewModel1, let submissionViewModel1, let showRubric1, let showSubmissionHistory1, _, _),  .GradeAndSubmission(let gradeViewModel2, let submissionViewModel2, let showRubric2, let showSubmissionHistory2, _, _)):
        return gradeViewModel1 == gradeViewModel2 && submissionViewModel1 == submissionViewModel2 && showRubric1 == showRubric2 && showSubmissionHistory1 == showSubmissionHistory2
    case let (.Title(title1), .Title(title2)):
        return title1 == title2
    case let (.Details(url1, details1), .Details(url2, details2)):
        return url1 == url2 && details1 == details2
    case let (.Padding(hidden1), .Padding(hidden2)):
        return hidden1 == hidden2
    default: return false
    }
}
