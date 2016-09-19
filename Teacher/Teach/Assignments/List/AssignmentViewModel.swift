//
//  AssignmentViewModel.swift
//  Teach
//
//  Created by Derrick Hathaway on 6/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import AssignmentKit
import SoPersistent
import ReactiveCocoa
import SoPretty
import SoLazy
import EnrollmentKit
import TooLegit
import SoIconic

extension Assignment {
    // TODO: one day this should be moved to AssignmentKit
    var iconicIcon: UIImage {
        switch submissionTypes {
        case [.DiscussionTopic]:
            return .icon(.discussion)
        case [.ExternalTool]:
            return .icon(.lti)
        case [.Quiz]:
            return .icon(.quiz)
        default:
            return .icon(.assignment)
        }
    }
    
    var iconA11yLabel: String {
        switch submissionTypes {
        case [.DiscussionTopic]:
            return NSLocalizedString("Discussion", comment: "Discussion assignment type")
        case [.Quiz]:
            return NSLocalizedString("Quiz", comment: "Quiz assignment type")
        case [.ExternalTool]:
            return NSLocalizedString("LTI", comment: "LTI tool assignment type")
        default:
            return NSLocalizedString("Assignment", comment: "Plain old assignment (not a quiz or a discussion)")
        }
    }
    
    var gradingStatus: String {
        switch (needsGradingCount, submissionTypes) {
        case (0, [.DiscussionTopic]):
            return NSLocalizedString("All responses have been graded", comment: "Discussion topic responses have been graded")
        case (1, [.DiscussionTopic]):
            return NSLocalizedString("1 response needs grading", comment: "only one discussion response needs grading")
        case (let count, [.DiscussionTopic]):
            return NSLocalizedString("\(count) responses need grading", comment: "N responses need to be graded")
            
        case (0, _):
            return NSLocalizedString("All submissions have been graded", comment: "Assignment grading status")
        case (1, _):
            return NSLocalizedString("1 submission needs grading", comment: "only one item needs to be graded")
        default:
            return NSLocalizedString("\(needsGradingCount) submissions need grading", comment: "More than 1 submission needs grading")
        }
    }
}

struct AssignmentViewModel: TableViewCellViewModel {
    private let color = MutableProperty(UIColor.prettyGray())
    private let icon: UIImage
    private let iconA11yLabel: String
    private let title: String
    private let subtitle: String
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: "AssignmentCell", bundle: NSBundle(forClass: AssignmentCell.self)), forCellReuseIdentifier: "AssignmentCell")
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentCell") as? AssignmentCell else {
            ❨╯°□°❩╯⌢"Need a cell of type AssignmentCell"
        }

        cell.prepare(icon, iconA11yLabel: iconA11yLabel, title: title, subtitle: subtitle)
        cell.observe(color)
        return cell
    }
    
    init(assignment: Assignment, session: Session) {
        icon = assignment.iconicIcon
        iconA11yLabel = assignment.iconA11yLabel
        title = assignment.name
        subtitle = assignment.gradingStatus
        
        let contextID = ContextID(id: assignment.courseID, context: .Course)
        color <~ session
            .enrollmentsDataSource
            .producer(contextID)
            .map { $0?.color ?? .prettyGray() }
    }
}
