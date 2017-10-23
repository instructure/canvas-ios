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

struct CalendarEventCellViewModel: TableViewCellViewModel {
    static var subtitleDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    static let reuseIdentifier = "CalendarEventCell"
    static let nibName = "CalendarEventCell"

    let name: String
    let subtitle: String
    let image: UIImage?
    let submittedText: String
    let submittedColor: UIColor
    let submittedImage: UIImage?
    let highlightColor: UIColor

    let calendarEvent: CalendarEvent

    init(calendarEvent: CalendarEvent, courseName: String?, highlightColor: UIColor) {
        self.calendarEvent = calendarEvent
        name = calendarEvent.title ?? ""
        subtitle = courseName ?? ""
        image = calendarEvent.type.image()
        submittedText = calendarEvent.submittedText
        submittedColor = calendarEvent.submittedColor
        submittedImage = calendarEvent.submittedImage
        self.highlightColor = highlightColor
    }
    
    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.estimatedRowHeight = 76
        tableView.register(UINib(nibName: "CalendarEventCell", bundle: Bundle(for: AppDelegate.self)), forCellReuseIdentifier: "CalendarEventCellViewModel")
    }
    
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventCellViewModel", for: indexPath) as? CalendarEventCell else {
            fatalError("Incorrect Cell Type Found Expected: CalendarEventTableViewCell")
        }

        cell.highlightColor = highlightColor
        cell.titleLabel.text = name
        cell.courseNameLabel.text = subtitle
        cell.typeImageView.tintColor = UIColor.white
        cell.typeImageView.backgroundColor = submittedColor
        cell.statusLabel.text = submittedText
        cell.statusLabel.backgroundColor = submittedColor

        let imageSize = CGSize(width: CalendarEventCell.iconImageDiameter-CalendarEventCell.iconSubtrator, height: CalendarEventCell.iconImageDiameter-CalendarEventCell.iconSubtrator)
        let smallImage = submittedImage?.imageScaledToSize(imageSize) ?? image?.imageScaledToSize(imageSize)
        cell.typeImageView.contentMode = .center
        cell.typeImageView.image = smallImage?.withRenderingMode(.alwaysTemplate)

        cell.titleLabel.accessibilityIdentifier = "event_title_\(indexPath.section)_\(indexPath.row)"
        cell.courseNameLabel.accessibilityIdentifier = "event_course_\(indexPath.section)_\(indexPath.row)"
        cell.typeImageView.accessibilityIdentifier = "event_icon_\(indexPath.section)_\(indexPath.row)"
        cell.statusLabel.accessibilityIdentifier = "event_status_\(indexPath.section)_\(indexPath.row)"

        return cell
    }
    
}

extension EventType {
    func image()->UIImage? {
        switch(self) {
        case .assignment:
            return UIImage(named: "icon_assignment_fill")
        case .quiz:
            return UIImage(named: "icon_quiz_fill")
        case .discussion:
            return UIImage(named: "icon_discussion_fill")
        case .calendarEvent:
            return UIImage(named: "icon_calendar_event_fill")
        case .error:
            return UIImage(named: "icon_assignment_fill")
        }
    }
}
