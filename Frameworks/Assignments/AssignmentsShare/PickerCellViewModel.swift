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
import SoPersistent
import AssignmentKit
import ReactiveSwift
import SoLazy
import Cartography
import FileKit

struct PickerCellViewModel: TableViewCellViewModel {

    let label: String
    var accessoryType: UITableViewCellAccessoryType = .none
    var userInteractionEnabled = true

    init(label: String) {
        self.label = label
    }

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "picker_cell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "picker_cell") else {
            ❨╯°□°❩╯⌢"Incorrect Cell Type Found Expected: picker_cell"
        }
        cell.textLabel?.text = label
        cell.accessoryType = accessoryType
        cell.isUserInteractionEnabled = userInteractionEnabled
        cell.textLabel?.textColor = UIColor.black
        if !userInteractionEnabled {
            cell.textLabel?.textColor = UIColor.lightGray
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
    let context: NSExtensionContext
    let selected: Bool
    let uploadAlreadyInProgress: Bool

    let submissions: MutableProperty<[OldNewSubmission]> = MutableProperty([])
    let spinning = MutableProperty(true)
    let submittable = MutableProperty(false)

    init(assignment: Assignment, context: NSExtensionContext, selected: Bool, uploadAlreadyInProgress: Bool) {
        self.assignment = assignment
        self.context = context
        self.selected = selected
        self.uploadAlreadyInProgress = uploadAlreadyInProgress

        submittable <~ submissions.producer.map { !self.uploadAlreadyInProgress && !$0.isEmpty }

        spinning.value = true
        assignment.submissions(for: context.attachments) { [weak self] result in
            self?.spinning.value = false
            self?.submissions.value = result.value ?? []
        }
    }

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(SpinnerTableViewCell.self, forCellReuseIdentifier: "pick_assignment_cell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pick_assignment_cell") as? SpinnerTableViewCell else {
            ❨╯°□°❩╯⌢"expected pick_assignment_cell"
        }

        cell.textLabel?.text = assignment.name
        spinning.producer.observe(on: UIScheduler()).startWithValues { spinning in
            spinning ? cell.spinner.startAnimating() : cell.spinner.stopAnimating()
            cell.textLabel?.isHidden = spinning
            cell.spinner.isHidden = !spinning
        }
        cell.accessoryType = selected ? .checkmark : .none

        submittable.producer.observe(on: UIScheduler()).startWithValues { submittable in
            cell.textLabel?.textColor = submittable ? UIColor.black : UIColor.lightGray
            cell.isUserInteractionEnabled = submittable
            if !submittable {
                if self.uploadAlreadyInProgress {
                    cell.detailTextLabel?.text = NSLocalizedString("Assignment is currently being submitted", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Message indicating that an assignment is currently be submitted")
                } else {
                    cell.detailTextLabel?.text = NSLocalizedString("Submission type not allowed", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Message indicating that a submission type is not supported for this assignment.")
                }
            } else {
                cell.detailTextLabel?.text = ""
            }
        }

        return cell
    }
}

class SpinnerTableViewCell: UITableViewCell {
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

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
