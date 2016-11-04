
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
    
    

import Foundation
import SoPersistent
import AssignmentKit
import SoLazy
import ReactiveCocoa
import Result
import EnrollmentKit
import WhizzyWig

extension UITraitCollection {
    var detailPadding: CGFloat {
        return horizontalSizeClass == .Regular ? 40.0 : 20.0
    }
}

enum AssignmentDetail: TableViewCellViewModel, Equatable {
    case Title(String)
    case Heading(String)
    case PointsPossible(colorProducer:SignalProducer<UIColor, NoError>, points: Double)
    case Published(colorProducer:SignalProducer<UIColor, NoError>, isPublished: Bool)
    case Due(colorProducer:SignalProducer<UIColor, NoError>, title: String, date: NSDate?)
    case Details(html: String, baseURL: NSURL)
    
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.registerClass(WhizzyWigTableViewCell.self, forCellReuseIdentifier: "DetailsDetailCell")
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        
        func dequeue(id: String) -> UITableViewCell {
            return tableView.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath)
        }
        
        let detailCell: UITableViewCell
        
        switch self {
            
        case let .Title(title):
            guard let cell = dequeue("TitleDetailCell") as? TitleDetailCell else { ❨╯°□°❩╯⌢"Title Detail" }
            cell.titleLabel.text = title
            detailCell = cell
            
            
        case let .Heading(heading):
            guard let cell = dequeue("HeadingDetailCell") as? HeadingDetailCell else { ❨╯°□°❩╯⌢"Heading Detail" }
            cell.headingLabel.text = heading
            detailCell = cell
            
            
        case let .PointsPossible(color, points):
            guard let cell = dequeue("SettingDetailCell") as? SettingDetailCell else { ❨╯°□°❩╯⌢"Setting Detail" }
            cell.titleLabel.text = NSLocalizedString("Points", comment: "Label for points possible on an assignment")
            cell.settingLabel.text = "\(Int(points))"
            let cvm = ColorfulViewModel(style: .Basic)
            cvm.color <~ color
            cell.viewModel = cvm
            detailCell = cell
            
            
        case let .Published(color, isPublished):
            guard let cell = dequeue("PublishedDetailCell") as? PublishedDetailCell else { ❨╯°□°❩╯⌢"Published detail" }
            cell.titleLabel.text = isPublished ? NSLocalizedString("Published", comment: "Assignment is published") : NSLocalizedString("Unpublished", comment: "Assignment is not published")
            cell.switchControl.on = isPublished
            let cvm = ColorfulViewModel(style: .Basic)
            cvm.color <~ color
            cell.viewModel = cvm
            detailCell = cell
            
            
        case let .Due(color, title, date):
            guard let cell = dequeue("DateDetailCell") as? DateDetailCell else { ❨╯°□°❩╯⌢"Date Detail" }
            cell.titleLabel.text = title
            cell.dateLabel.text = date
                .map { $0.formattedDueDate } ??
                NSLocalizedString("No Due Date", comment: "When an assignment has no due date")
            let cvm = ColorfulViewModel(style: .Basic)
            cvm.color <~ color
            cell.viewModel = cvm
            detailCell = cell
            
            
        case let .Details(deets, baseURL):
            guard let cell = dequeue("DetailsDetailCell") as? WhizzyWigTableViewCell else { ❨╯°□°❩╯⌢"Details Detail" }
            cell.whizzyWigView.loadHTMLString(deets, baseURL: baseURL)
            cell.cellSizeUpdated = { [weak tableView] _ in
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            detailCell = cell
        }
        
        if let cell = detailCell as? DetailCell {
            cell.paddingConstraints.forEach { $0.constant = tableView.traitCollection.detailPadding }
        }
        
        return detailCell
    }
    
    static func details(baseURL: NSURL, color: SignalProducer<UIColor, NoError>) -> (assignment: Assignment) -> [AssignmentDetail] {
        return { assignment in
            let staticConfig: [AssignmentDetail] = [
                .Title(assignment.name),
                .Published(colorProducer: color, isPublished: assignment.published),
                .PointsPossible(colorProducer: color, points: assignment.pointsPossible),
                .Heading(NSLocalizedString("Due", comment: "Heading for the list of due dates")),
            ]
            
            let dueOverrides = Array(assignment.dueDateOverrides ?? [])
                .sort { lhs, rhs in
                    lhs.title < rhs.title
                }
                .map { AssignmentDetail.Due(colorProducer: color, title: $0.title, date: $0.due) }
            
            let dueTitle: String
            if dueOverrides.count > 0 {
                dueTitle = NSLocalizedString("Everyone Else", comment: "due date for everyone not in an override")
            } else {
                dueTitle = NSLocalizedString("Everyone", comment: "due date for everyone")
            }
            let due = AssignmentDetail.Due(colorProducer: color, title: dueTitle, date: assignment.due)
            
            let details: [AssignmentDetail] = [
                .Heading(NSLocalizedString("Description", comment: "The description of the assignment")),
                .Details(html: assignment.details, baseURL: baseURL),
            ]
            
            return staticConfig
                + dueOverrides
                + [due]
                + details
        }
    }
}

func ==(lhs: AssignmentDetail, rhs: AssignmentDetail) -> Bool {
    switch (lhs, rhs) {
    case let (.Title(left), .Title(right)):
        return left == right
    case let (.Heading(left), .Heading(right)):
        return left == right
    case let (.PointsPossible(_, left), .PointsPossible(colorProducer: _, points: right)):
        return left == right
    case let (.Published(_, left), .Published(_, right)):
        return left == right
    case let (.Due(_, lTitle, lDate), .Due(_, rTitle, rDate)):
        return lTitle == rTitle && lDate == rDate
    case let (.Details(lHTML, lURL), .Details(rHTML, rURL)):
        return lHTML == rHTML && lURL == rURL
    default:
        return false
    }
}

