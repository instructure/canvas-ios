
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
import ObserverAlertKit
import SoLazy
import TooLegit

struct AlertCellViewModel: TableViewCellViewModel {

    let alert: Alert
    let highlightColor: UIColor
    let session: Session

    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    init(alert: Alert, highlightColor: UIColor, session: Session) {
        self.alert = alert
        self.highlightColor = highlightColor
        self.session = session
    }

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: "AlertCell", bundle: NSBundle(forClass: AlertCell.self)), forCellReuseIdentifier: "AlertCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("AlertCell", forIndexPath: indexPath) as? AlertCell else {
            fatalError("Incorrect cell type found. Expected: AlertCell")
        }

        cell.highlightColor = highlightColor
        cell.titleLabel.text = alert.title
        cell.dateLabel.text = AlertCellViewModel.dateFormatter.stringFromDate(alert.actionDate)
        cell.alert = alert
        cell.session = session

        if alert.read {
            cell.titleLabel.textColor = UIColor.prettyGray()
            cell.dateLabel.textColor = UIColor.prettyGray()
        } else {
            cell.titleLabel.textColor = UIColor.blackColor()
            cell.dateLabel.textColor = UIColor.prettyGray()
        }

        let imageName: String
        let color: UIColor

        switch alert.type {
        case .InstitutionAnnouncement, .CourseAnnouncement:
            imageName = "icon_announcements_fill"
            color = UIColor.parentBlueColor()
        case .AssignmentMissing, .AssignmentGradeLow, .CourseGradeLow:
            imageName = "icon_alert_fill"
            color = UIColor.parentRedColor()
        case .AssignmentGradeHigh, .CourseGradeHigh:
            imageName = "icon_favorite_fill"
            color = UIColor.parentBlueColor()
        case .Unknown:
            imageName = ""
            color = UIColor.clearColor()
        }

        switch alert.type {
        case .CourseGradeLow, .CourseGradeHigh:
            cell.selectionStyle = .None // lets not show anything in this case
        default:
            cell.selectionStyle = .Default
        }

        let image = UIImage(named: imageName, inBundle: NSBundle(forClass: AlertCell.self), compatibleWithTraitCollection: nil)
        cell.iconImageView.image = image?.imageScaledToSize(CGSize(width: AlertCell.iconImageDiameter-15, height: AlertCell.iconImageDiameter-15)).imageWithRenderingMode(.AlwaysTemplate)
        cell.iconImageView.backgroundColor = color
        cell.iconImageView.tintColor = UIColor.whiteColor()
        cell.iconImageView.contentMode = .Center
        cell.iconImageView.layer.cornerRadius = AlertCell.iconImageDiameter / 2

        cell.titleLabel.accessibilityIdentifier = "alert_cell_title_\(indexPath.row)"
        cell.dateLabel.accessibilityIdentifier = "alert_cell_date_\(indexPath.row)"

        return cell
    }
}
