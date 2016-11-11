//
//  MasteryPathAssignmentPreviewViewController.swift
//  Canvas
//
//  Created by Ben Kraus on 10/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoPersistent
import SoEdventurous
import TooLegit
import WhizzyWig

private enum AssignmentPreviewViewModel: TableViewCellViewModel {
    case Info(name: String, dueDate: NSDate?, points: Double)
    case Details(baseURL: NSURL, deets: String)

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 52.0
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "MasteryPathAssignmentInfoCell", bundle: nil), forCellReuseIdentifier: "Info")
        tableView.registerClass(WhizzyWigTableViewCell.self, forCellReuseIdentifier: "Deets")
    }

    static let dueDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true
        formatter.locale = NSLocale.currentLocale()
        return formatter
    }()

    private func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch self {
        case .Info(let name, let dueDate, let points):
            let cell = tableView.dequeueReusableCellWithIdentifier("Info", forIndexPath: indexPath) as! MasteryPathAssignmentInfoCell
            cell.titleLabel.text = name
            cell.titleLabel.accessibilityIdentifier = "info_title_label"
            if let dueDate = dueDate {
                let template = NSLocalizedString("Due %@", comment: "Formatted string for showing an assingment due date (date already localized by system)")
                cell.dueDateLabel.text = String.localizedStringWithFormat(template, AssignmentPreviewViewModel.dueDateFormatter.stringFromDate(dueDate))
                cell.dueDateLabel.accessibilityIdentifier = "info_due_date_label"
            } else {
                cell.contentStackView.arrangedSubviews[1].hidden = true
            }
            let pointsFormatter = NSNumberFormatter()
            pointsFormatter.numberStyle = .DecimalStyle
            let template = NSLocalizedString("%@ pts", comment: "Shows points possible for an assignment")
            cell.pointsPossibleLabel.text = String.localizedStringWithFormat(template, pointsFormatter.stringFromNumber(NSNumber(double: points)) ?? "")
            cell.pointsPossibleLabel.accessibilityIdentifier = "info_points_label"
            cell.accessibilityIdentifier = "info_cell"
            return cell
        case .Details(let baseURL, let deets):
            let cell = tableView.dequeueReusableCellWithIdentifier("Deets", forIndexPath: indexPath) as! WhizzyWigTableViewCell
            cell.whizzyWigView.useAPISafeLinks = false
            cell.whizzyWigView.contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            cell.whizzyWigView.loadHTMLString(deets, baseURL: baseURL)
            cell.whizzyWigView.accessibilityIdentifier = "details_html_body"
            cell.cellSizeUpdated = { [weak tableView] _ in
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            cell.accessibilityIdentifier = "details_cell"
            return cell
        }
    }

    static func detailsForAssignment(baseURL: NSURL) -> (assignment: MasteryPathAssignment) -> [AssignmentPreviewViewModel] {
        return { assignment in
            return [ .Info(name: assignment.name, dueDate: assignment.due, points: assignment.pointsPossible), .Details(baseURL: baseURL, deets: assignment.details) ]
        }
    }
}

extension AssignmentPreviewViewModel: Equatable { }
private func ==(lhs: AssignmentPreviewViewModel, rhs: AssignmentPreviewViewModel) -> Bool {
    switch(lhs, rhs) {
    case let (.Info(leftName, leftDueDate, leftPointsPossible), .Info(rightName, rightDueDate, rightPointsPossible)):
        return leftName == rightName && leftDueDate == rightDueDate && leftPointsPossible == rightPointsPossible
    case let (.Details(leftURL, leftDeets), .Details(rightURL, rightDeets)):
        return (leftURL == rightURL) && (leftDeets == rightDeets)
    default:
        return false
    }
}


class MasteryPathAssignmentPreviewViewController: MasteryPathAssignment.DetailViewController {

    let session: Session
    let assignment: MasteryPathAssignment

    init(session: Session, assignment: MasteryPathAssignment) throws {
        self.session = session
        self.assignment = assignment

        super.init()

        let observer = try MasteryPathAssignment.observer(session, id: assignment.id)
        prepare(observer, detailsFactory: AssignmentPreviewViewModel.detailsForAssignment(session.baseURL))

        navigationItem.title = NSLocalizedString("Details", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

