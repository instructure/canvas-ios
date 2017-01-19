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
    
    case gradeAndSubmission(GradeViewModel, SubmissionStatusViewModel, Bool, Bool, RoutingHandler, RoutingHandler)
    case title(Assignment)
    case details(URL, String)
    case padding(Bool)
    
    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
    }
    
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .gradeAndSubmission(let gradeViewModel, let submissionViewModel, let showRubric, let showSubmissionHistory, let rubricHandler, let submissionHandler):
            let cell = tableView.dequeueReusableCell(withIdentifier: "gradeSubmissionsTableViewCell") as! AssignmentGradeSubmissionTableViewCell
            
            let gradeView = CircularGradeView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
            gradeView.setGrade(gradeViewModel, animated: true)
            gradeView.setupRubricButton(showRubric, buttonPressHandler: rubricHandler)
            
            let submissionStatusView = SubmissionStatusView(frame: CGRect(x: 0, y: 0, width: 160, height: 160), viewModel: submissionViewModel, showSubmissionHistory: showSubmissionHistory)
            submissionStatusView.viewSubmissionDetailsPressedHandler = submissionHandler
            
            cell.leftView.backgroundColor = UIColor.clear
            cell.rightView.backgroundColor = UIColor.clear
            
            cell.leftView.addSubview(gradeView)
            cell.rightView.addSubview(submissionStatusView)
            
            cell.verticalLineWidth.constant = 1/UIScreen.main.scale
            
            var viewBindingsDict = [String: AnyObject]()
            viewBindingsDict["gradeView"] = gradeView
            
            cell.leftView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[gradeView(==160)]|", options: [], metrics: nil, views: viewBindingsDict))
            cell.leftView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[gradeView(==160)]|", options: [], metrics: nil, views: viewBindingsDict))
            
            return cell
        case .title(let assignment):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentInfoCell") else { ❨╯°□°❩╯⌢"expected assignmentInfoCell" }
            allowMultipleLines(cell)
            
            let due = NSLocalizedString("Due: ", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "String telling the user that the date is the due date")
            
            let dueDateFormatter = DateFormatter()
            dueDateFormatter.dateStyle = DateFormatter.Style.medium
            dueDateFormatter.timeStyle = .short
            
            let dueDate = (assignment.due != nil) ? due + dueDateFormatter.string(from: assignment.due!) : NSLocalizedString("No Due Date", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Default string for due date title")
            
            cell.textLabel?.text = assignment.name
            cell.detailTextLabel?.text = assignment.lockedForUser == true ? assignment.lockExplanation : dueDate
            
            
            return cell
        case .details(let baseURL, let deets):
            let cell = WhizzyWigTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "theWhizz")
            cell.whizzyWigView.loadHTMLString(deets, baseURL: baseURL)
            cell.cellSizeUpdated = { [weak tableView] _ in
                tableView?.beginUpdates()
                UIView.setAnimationsEnabled(false)
                tableView?.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                UIView.setAnimationsEnabled(true)
                tableView?.endUpdates()
            }
            cell.selectionStyle = .none
            
            return cell
        case .padding(let hidden):
            let cell = tableView.dequeueReusableCell(withIdentifier: "paddingCell") as! AssignmentPaddingCell
            cell.horizontalLineView.isHidden = hidden
            cell.horizontalLineHeight.constant = 1/UIScreen.main.scale
            return cell
        }
    }
    
    fileprivate func allowMultipleLines(_ tableViewCell:UITableViewCell) {
        tableViewCell.textLabel?.numberOfLines = 0
        tableViewCell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        tableViewCell.detailTextLabel?.numberOfLines = 0
        tableViewCell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    static func detailsForAssignment(_ session: Session, viewRubricHandler: @escaping RoutingHandler, viewSubmissionsHandler: @escaping RoutingHandler) -> (_ assignment: Assignment) -> [AssignmentDetailCellViewModel] {
        return { assignment in
            
            let enrollmentDataSource = session.enrollmentsDataSource[ContextID(id:assignment.courseID, context: .course)]
            let isTeacher = enrollmentDataSource?.roles?.contains(EnrollmentRoles.Teacher) ?? false
            
            var cells : [AssignmentDetailCellViewModel] = [
                .gradeAndSubmission(GradeViewModel.gradeViewModelForAssignment(assignment), SubmissionStatusViewModel(assignment: assignment), assignment.rubric != nil, !isTeacher && assignment.hasSubmitted && assignment.allowsSubmissions, viewRubricHandler, viewSubmissionsHandler),
                .padding(false),
                .title(assignment),
                .padding(true)
            ]
            
            if assignment.lockedForUser == true && assignment.canView == false {
                cells += [.padding(true)]
            } else {
                cells += [.details(session.baseURL, assignment.details)]
            }
            
            return cells
        }
    }
}

// MARK: - Equatable

extension AssignmentDetailCellViewModel: Equatable {}
func ==(lhs: AssignmentDetailCellViewModel, rhs: AssignmentDetailCellViewModel) -> Bool {
    switch (lhs, rhs) {
    case (.gradeAndSubmission(let gradeViewModel1, let submissionViewModel1, let showRubric1, let showSubmissionHistory1, _, _),  .gradeAndSubmission(let gradeViewModel2, let submissionViewModel2, let showRubric2, let showSubmissionHistory2, _, _)):
        return gradeViewModel1 == gradeViewModel2 && submissionViewModel1 == submissionViewModel2 && showRubric1 == showRubric2 && showSubmissionHistory1 == showSubmissionHistory2
    case let (.title(title1), .title(title2)):
        return title1 == title2
    case let (.details(url1, details1), .details(url2, details2)):
        return url1 == url2 && details1 == details2
    case let (.padding(hidden1), .padding(hidden2)):
        return hidden1 == hidden2
    default: return false
    }
}
