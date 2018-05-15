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

private let TitleCellReuseIdentifier = "TitleCell"
private let ReminderCellReuseIdentifier = "ReminderCell"
private let DateCellReuseIdentifier = "DueDateCell"
private let LocationCellReuseIdentifier = "LocationCell"
private let DetailsCellReuseIdentifier = "DetailsCell"

enum EventDetailsViewModel: TableViewCellViewModel {

    case info(name: String, submissionInfo: String?, submissionColor: UIColor?)
    case reminder(date: Date?, remindable: Remindable, actionURL: URL, context: UIViewController)
    case date(start: Date, end: Date, allDay: Bool)
    case location(locationName: String?, address: String?)
    case details(baseURL: URL, deets: String)

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 52.0
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "DetailsInfoCell", bundle: nil), forCellReuseIdentifier: TitleCellReuseIdentifier)
        tableView.register(UINib(nibName: "DetailsReminderCell", bundle: nil), forCellReuseIdentifier: ReminderCellReuseIdentifier)
        tableView.register(UINib(nibName: "DetailsDateCell", bundle: nil), forCellReuseIdentifier: DateCellReuseIdentifier)
        tableView.register(UINib(nibName: "DetailsLocationCell", bundle: nil), forCellReuseIdentifier: LocationCellReuseIdentifier)
        tableView.register(DetailsDescriptionCell.self, forCellReuseIdentifier: DetailsCellReuseIdentifier)
    }

    static var dateFormatter: DateIntervalFormatter = {
        let dateFormatter = DateIntervalFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    static var allDayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .info(let name, let submissionInfo, let submissionColor):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleCellReuseIdentifier, for: indexPath) as? DetailsInfoCell else { fatalError() }
            cell.titleLabel.text? = name
            cell.submissionLabel.text = submissionInfo ?? ""
            cell.submissionLabel.backgroundColor = submissionColor
            cell.setShowsSubmissionInfo(submissionInfo?.isEmpty == false)
            return cell

        case .date(let startDate, let endDate, let allDay):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DateCellReuseIdentifier, for: indexPath) as? DetailsDateCell else { fatalError() }

            let date: String
            if allDay {
                date = EventDetailsViewModel.allDayDateFormatter.string(from: startDate)
            } else {
                date = EventDetailsViewModel.dateFormatter.string(from: startDate, to: endDate)
            }

            cell.dateLabel.text = date

            return cell

        case .reminder(let date, let remindable, let actionURL, let context):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCellReuseIdentifier, for: indexPath) as? DetailsReminderCell else { fatalError() }
            cell.toggle.isOn = (date != nil)
            cell.setExpanded((date != nil))
            if let date = date {
                cell.dateLabel.text = DetailsReminderCell.dateFormatter.string(from: date)
            } else {
                cell.dateLabel.text = ""
            }

            cell.cellSizeUpdated = { [weak tableView] in
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            cell.toggleAction = { [weak tableView] on in
                if on {
                    let vc = DatePickerViewController()
                    vc.cancelAction = {
                        cell.toggle.setOn(false, animated: true)
                    }
                    vc.doneAction = { date in
                        remindable.scheduleReminder(atTime: date, actionURL: actionURL)
                        cell.dateLabel.text = DetailsReminderCell.dateFormatter.string(from: date)
                        cell.setExpanded(true)
                        tableView?.beginUpdates()
                        tableView?.endUpdates()
                    }
                    vc.datePicker.date = max(Date(), remindable.defaultReminderDate) // never let it go into the past
                    vc.datePicker.minimumDate = Date()
                    let nav = SmallModalNavigationController(rootViewController: vc)
                    nav.navigationBar.barStyle = .black
                    nav.navigationBar.barTintColor = .white
                    context.present(nav, animated: true, completion: nil)
                } else {
                    remindable.cancelReminder()
                    cell.dateLabel.text = ""
                    cell.setExpanded(false)
                    tableView?.beginUpdates()
                    tableView?.endUpdates()
                }
            }
            return cell
        case .location(let locationName, let address):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationCellReuseIdentifier, for: indexPath) as? DetailsLocationCell else { fatalError() }
            let components = [locationName, address].flatMap { $0 }.filter { !$0.isEmpty }
            cell.locationLabel.text = components.joined(separator: "\n")
            return cell

        case .details(let baseURL, let deets):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailsCellReuseIdentifier, for: indexPath) as? WhizzyWigTableViewCell else { fatalError() }
            cell.whizzyWigView.useAPISafeLinks = false
            cell.whizzyWigView.loadHTMLString(deets, baseURL: baseURL)
            cell.cellSizeUpdated = { [weak tableView] _ in
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            cell.whizzyWigView.accessibilityIdentifier = "event_details"
            return cell
        }
    }
}

extension EventDetailsViewModel: Equatable { }
func ==(lhs: EventDetailsViewModel, rhs: EventDetailsViewModel) -> Bool {
    switch(lhs, rhs) {
    case let (.info(leftName, leftSubmissionInfo, _), .info(rightName, rightSubmissionInfo, _)):
        return leftName == rightName && leftSubmissionInfo == rightSubmissionInfo
    case let (.date(leftStartDate, leftEndDate, leftAllDay), .date(rightStartDate, rightEndDate, rightAllDay)):
        return (leftStartDate == rightStartDate) && (leftEndDate == rightEndDate) && (leftAllDay == rightAllDay)
    case let (.reminder(leftDate, _, _, _), .reminder(rightDate, _, _, _)):
        return leftDate == rightDate
    case let (.location(leftName, leftAddress), .location(rightName, rightAddress)):
        return (leftName == rightName) && (leftAddress == rightAddress)
    case let (.details(leftURL, leftDeets), .details(rightURL, rightDeets)):
        return (leftURL == rightURL) && (leftDeets == rightDeets)
    default:
        return false
    }
}
