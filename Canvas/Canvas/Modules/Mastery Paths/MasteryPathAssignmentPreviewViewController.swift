//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CanvasCore

private enum AssignmentPreviewViewModel: TableViewCellViewModel {
    case info(name: String, dueDate: Date?, points: Double)
    case details(baseURL: URL, deets: String)

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 52.0
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "MasteryPathAssignmentInfoCell", bundle: nil), forCellReuseIdentifier: "Info")
        tableView.register(WhizzyWigTableViewCell.self, forCellReuseIdentifier: "Deets")
    }

    static let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        formatter.locale = Locale.current
        return formatter
    }()

    fileprivate func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .info(let name, let dueDate, let points):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath) as! MasteryPathAssignmentInfoCell
            cell.titleLabel.text = name
            cell.titleLabel.accessibilityIdentifier = "info_title_label"
            if let dueDate = dueDate {
                let template = NSLocalizedString("Due %@", comment: "Formatted string for showing an assingment due date (date already localized by system)")
                cell.dueDateLabel.text = String.localizedStringWithFormat(template, AssignmentPreviewViewModel.dueDateFormatter.string(from: dueDate))
                cell.dueDateLabel.accessibilityIdentifier = "info_due_date_label"
            } else {
                cell.contentStackView.arrangedSubviews[1].isHidden = true
            }
            let pointsFormatter = NumberFormatter()
            pointsFormatter.numberStyle = .decimal
            let template = NSLocalizedString("%@ pts", comment: "Shows points possible for an assignment")
            cell.pointsPossibleLabel.text = String.localizedStringWithFormat(template, pointsFormatter.string(from: NSNumber(value: points as Double)) ?? "")
            cell.pointsPossibleLabel.accessibilityIdentifier = "info_points_label"
            cell.accessibilityIdentifier = "info_cell"
            return cell
        case .details(let baseURL, let deets):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Deets", for: indexPath) as! WhizzyWigTableViewCell
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

    static func detailsForAssignment(_ baseURL: URL) -> (_ assignment: MasteryPathAssignment) -> [AssignmentPreviewViewModel] {
        return { assignment in
            return [ .info(name: assignment.name, dueDate: assignment.due, points: assignment.pointsPossible), .details(baseURL: baseURL, deets: assignment.details) ]
        }
    }
}

extension AssignmentPreviewViewModel: Equatable { }
private func ==(lhs: AssignmentPreviewViewModel, rhs: AssignmentPreviewViewModel) -> Bool {
    switch(lhs, rhs) {
    case let (.info(leftName, leftDueDate, leftPointsPossible), .info(rightName, rightDueDate, rightPointsPossible)):
        return leftName == rightName && leftDueDate == rightDueDate && leftPointsPossible == rightPointsPossible
    case let (.details(leftURL, leftDeets), .details(rightURL, rightDeets)):
        return (leftURL == rightURL) && (leftDeets == rightDeets)
    default:
        return false
    }
}


class MasteryPathAssignmentPreviewViewController: MasteryPathAssignmentDetailViewController {

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

