//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import CanvasCore
import Core

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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "AlertCell", bundle: Bundle(for: AlertCell.self)), forCellReuseIdentifier: "AlertCell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as? AlertCell else {
            fatalError("Incorrect cell type found. Expected: AlertCell")
        }

        cell.highlightColor = highlightColor
        cell.titleLabel.text = alert.title
        let unreadLabel = NSLocalizedString("Unread", comment: "")
        cell.titleLabel.accessibilityLabel = alert.read ? alert.title : "\(unreadLabel), \(alert.title)"
        cell.dateLabel.text = alert.actionDate.map(AlertCellViewModel.dateFormatter.string)
        cell.alert = alert
        cell.session = session

        if alert.read {
            cell.titleLabel.textColor = UIColor.prettyGray()
            cell.dateLabel.textColor = UIColor.prettyGray()
        } else {
            cell.titleLabel.textColor = UIColor.black
            cell.dateLabel.textColor = UIColor.prettyGray()
        }

        let iconName: UIImage.InstIconName
        let color: UIColor

        switch alert.type {
        case .institutionAnnouncement, .courseAnnouncement:
            iconName = .announcement
            color = UIColor.named(.textInfo)
        case .assignmentMissing, .assignmentGradeLow, .courseGradeLow:
            iconName = .warning
            color = UIColor.named(.textDanger)
        case .assignmentGradeHigh, .courseGradeHigh:
            iconName = .star
            color = UIColor.named(.textInfo)
        }

        switch alert.type {
        case .courseGradeLow, .courseGradeHigh:
            cell.selectionStyle = .none // lets not show anything in this case
        default:
            cell.selectionStyle = .default
        }

        let image = UIImage.icon(iconName, .solid)
        cell.iconImageView.image = image.imageScaledToSize(CGSize(width: AlertCell.iconImageDiameter-15, height: AlertCell.iconImageDiameter-15)).withRenderingMode(.alwaysTemplate)
        cell.iconImageView.backgroundColor = color
        cell.iconImageView.tintColor = UIColor.white
        cell.iconImageView.contentMode = .center
        cell.iconImageView.layer.cornerRadius = AlertCell.iconImageDiameter / 2

        cell.titleLabel.accessibilityIdentifier = "alert_cell_title_\(indexPath.row)"
        cell.dateLabel.accessibilityIdentifier = "alert_cell_date_\(indexPath.row)"

        return cell
    }
}
