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


import CanvasCore


struct AlertCellViewModel: TableViewCellViewModel {

    let alert: Alert
    let highlightColor: UIColor
    let session: Session

    fileprivate static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    init(alert: Alert, highlightColor: UIColor, session: Session) {
        self.alert = alert
        self.highlightColor = highlightColor
        self.session = session
    }

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "AlertCell", bundle: Bundle(for: AlertCell.self)), forCellReuseIdentifier: "AlertCell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as? AlertCell else {
            fatalError("Incorrect cell type found. Expected: AlertCell")
        }

        cell.highlightColor = highlightColor
        cell.titleLabel.text = alert.title
        cell.dateLabel.text = AlertCellViewModel.dateFormatter.string(from: alert.actionDate)
        cell.alert = alert
        cell.session = session

        if alert.read {
            cell.titleLabel.textColor = UIColor.prettyGray()
            cell.dateLabel.textColor = UIColor.prettyGray()
        } else {
            cell.titleLabel.textColor = UIColor.black
            cell.dateLabel.textColor = UIColor.prettyGray()
        }

        let imageName: String
        let color: UIColor

        switch alert.type {
        case .institutionAnnouncement, .courseAnnouncement:
            imageName = "icon_announcements_fill"
            color = UIColor.parentBlueColor()
        case .assignmentMissing, .assignmentGradeLow, .courseGradeLow:
            imageName = "icon_alert_fill"
            color = UIColor.parentRedColor()
        case .assignmentGradeHigh, .courseGradeHigh:
            imageName = "icon_favorite_fill"
            color = UIColor.parentBlueColor()
        case .unknown:
            imageName = ""
            color = UIColor.clear
        }

        switch alert.type {
        case .courseGradeLow, .courseGradeHigh:
            cell.selectionStyle = .none // lets not show anything in this case
        default:
            cell.selectionStyle = .default
        }

        let image = UIImage(named: imageName, in: Bundle(for: AlertCell.self), compatibleWith: nil)
        cell.iconImageView.image = image?.imageScaledToSize(CGSize(width: AlertCell.iconImageDiameter-15, height: AlertCell.iconImageDiameter-15)).withRenderingMode(.alwaysTemplate)
        cell.iconImageView.backgroundColor = color
        cell.iconImageView.tintColor = UIColor.white
        cell.iconImageView.contentMode = .center
        cell.iconImageView.layer.cornerRadius = AlertCell.iconImageDiameter / 2

        cell.titleLabel.accessibilityIdentifier = "alert_cell_title_\(indexPath.row)"
        cell.dateLabel.accessibilityIdentifier = "alert_cell_date_\(indexPath.row)"

        return cell
    }
}
