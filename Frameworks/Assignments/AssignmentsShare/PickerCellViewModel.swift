//
//  PickerCellViewModel.swift
//  Assignments
//
//  Created by Nathan Armstrong on 3/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent
import AssignmentKit
import ReactiveCocoa
import SoLazy
import Cartography
import FileKit

struct PickerCellViewModel: TableViewCellViewModel {

    let label: String
    var accessoryType: UITableViewCellAccessoryType = .None
    var userInteractionEnabled = true

    init(label: String) {
        self.label = label
    }

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "picker_cell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("picker_cell") else {
            ❨╯°□°❩╯⌢"Incorrect Cell Type Found Expected: picker_cell"
        }
        cell.textLabel?.text = label
        cell.accessoryType = accessoryType
        cell.userInteractionEnabled = userInteractionEnabled
        cell.textLabel?.textColor = UIColor.blackColor()
        if !userInteractionEnabled {
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }
        return cell
    }

}

/**
 ViewModel for displaying a pickable assignment cell
 
 - Note: The assignment is selectable if we can make a submission for it given the extension context.
         Determining the available submission types can be expensive so I've added a spinner that will
         be shown during that process. It's normally pretty quick so you may not ever see it.
 */
class PickAssignmentTableViewCellViewModel: TableViewCellViewModel {
    let assignment: Assignment
    let context: SubmissionExtensionContext
    let submissionBuilder: ShareSubmissionBuilder
    let selected: Bool
    let uploadAlreadyInProgress: Bool

    let submissions: MutableProperty<[NewUpload]> = MutableProperty([])
    let spinning = MutableProperty(true)
    let submittable = MutableProperty(false)

    init(assignment: Assignment, context: SubmissionExtensionContext, selected: Bool, uploadAlreadyInProgress: Bool) {
        self.assignment = assignment
        self.context = context
        self.selected = selected
        self.submissionBuilder = ShareSubmissionBuilder(assignment: assignment)
        self.uploadAlreadyInProgress = uploadAlreadyInProgress

        submittable <~ submissions.producer.map { !self.uploadAlreadyInProgress && !$0.isEmpty }

        submissionBuilder.submissionsForExtensionContext(context)
            .on(started: { self.spinning.value = true })
            .start { event in
                switch event {
                case let .Next(s): self.submissions.value.append(s)
                case .Completed, .Failed(_), .Interrupted: self.spinning.value = false
                }
            }
    }

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerClass(SpinnerTableViewCell.self, forCellReuseIdentifier: "pick_assignment_cell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("pick_assignment_cell") as? SpinnerTableViewCell else {
            ❨╯°□°❩╯⌢"expected pick_assignment_cell"
        }

        cell.textLabel?.text = assignment.name
        spinning.producer.observeOn(UIScheduler()).startWithNext { spinning in
            spinning ? cell.spinner.startAnimating() : cell.spinner.stopAnimating()
            cell.textLabel?.hidden = spinning
            cell.spinner.hidden = !spinning
        }
        cell.accessoryType = selected ? .Checkmark : .None

        submittable.producer.observeOn(UIScheduler()).startWithNext { submittable in
            cell.textLabel?.textColor = submittable ? UIColor.blackColor() : UIColor.lightGrayColor()
            cell.userInteractionEnabled = submittable
            if !submittable {
                if self.uploadAlreadyInProgress {
                    cell.detailTextLabel?.text = NSLocalizedString("Assignment is currently being submitted", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Message indicating that an assignment is currently be submitted")
                } else {
                    cell.detailTextLabel?.text = NSLocalizedString("Submission type not allowed", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Message indicating that a submission type is not supported for this assignment.")
                }
            } else {
                cell.detailTextLabel?.text = ""
            }
        }

        return cell
    }
}

class SpinnerTableViewCell: UITableViewCell {
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(spinner)
    }

    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"init(coder:) has not been implemented"
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        constrain(contentView, spinner) { contentView, spinner in
            spinner.centerY == contentView.centerY
            spinner.centerX == contentView.centerX
        }
    }
}
