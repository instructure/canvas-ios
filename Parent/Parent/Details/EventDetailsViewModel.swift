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
    case reminder(remindable: Remindable, actionURL: URL, context: UIViewController)
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

        case .reminder(let remindable, let actionURL, let context):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCellReuseIdentifier, for: indexPath) as? DetailsReminderCell else { fatalError() }
            remindable.getScheduledReminder { request in
                DispatchQueue.main.async {
                    let trigger = request?.trigger as? UNCalendarNotificationTrigger
                    var dateComponents = trigger?.dateComponents
                    dateComponents?.calendar = Calendar.current
                    let date = dateComponents?.date

                    cell.toggle.isOn = (date != nil)
                    cell.setExpanded((date != nil))
                    if let date = date {
                        cell.dateLabel.text = DetailsReminderCell.dateFormatter.string(from: date)
                    } else {
                        cell.dateLabel.text = ""
                    }
                }
            }

            cell.cellSizeUpdated = { [weak tableView] in
                tableView?.reloadData()
            }
            cell.toggleAction = { on in
                if on {
                    self.requestNotifications { success in
                        DispatchQueue.main.async {
                            if success {
                                self.scheduleRemindable(remindable, url: actionURL, forCell: cell, inTableView: tableView, inContext: context)
                            } else {
                                cell.toggle.isOn = false
                                self.resetReminderCell(cell, inTableView: tableView)
                                self.presentNotificationPermissionAlert(from: context)
                            }
                        }
                    }
                } else {
                    remindable.cancelReminder()
                    self.resetReminderCell(cell, inTableView: tableView)
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
                tableView?.reloadData()
            }
            cell.whizzyWigView.accessibilityIdentifier = "event_details"
            return cell
        }
    }

    func resetReminderCell(_ cell: DetailsReminderCell, inTableView tableView: UITableView) {
        cell.dateLabel.text = ""
        cell.setExpanded(false)
        tableView.reloadData()
    }

    func scheduleRemindable(_ remindable: Remindable, url: URL, forCell cell: DetailsReminderCell, inTableView tableView: UITableView, inContext context: UIViewController) {
        let vc = DatePickerViewController()
        vc.cancelAction = {
            cell.toggle.setOn(false, animated: true)
        }
        vc.doneAction = { date in
            remindable.scheduleReminder(atTime: date, actionURL: url) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        ErrorReporter.reportError(error as NSError, from: context)
                        cell.toggle.setOn(false, animated: true)
                        self.resetReminderCell(cell, inTableView: tableView)
                        return
                    }
                    cell.dateLabel.text = DetailsReminderCell.dateFormatter.string(from: date)
                    cell.setExpanded(true)
                    tableView.reloadData()
                }
            }
        }
        vc.datePicker.date = max(Date(), remindable.defaultReminderDate) // never let it go into the past
        vc.datePicker.minimumDate = Date()
        let nav = SmallModalNavigationController(rootViewController: vc)
        nav.navigationBar.barStyle = .black
        nav.navigationBar.barTintColor = .white
        context.present(nav, animated: true, completion: nil)
    }

    func requestNotifications(completionHandler: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            completionHandler(error == nil && success)
        }
    }

    func presentNotificationPermissionAlert(from viewController: UIViewController) {
        let title = NSLocalizedString("Permission Needed", comment: "")
        let message = NSLocalizedString("You must allow notifications in Settings to set reminders.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { _ in
                UIApplication.shared.open(url)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension EventDetailsViewModel: Equatable { }
func ==(lhs: EventDetailsViewModel, rhs: EventDetailsViewModel) -> Bool {
    switch(lhs, rhs) {
    case let (.info(leftName, leftSubmissionInfo, _), .info(rightName, rightSubmissionInfo, _)):
        return leftName == rightName && leftSubmissionInfo == rightSubmissionInfo
    case let (.date(leftStartDate, leftEndDate, leftAllDay), .date(rightStartDate, rightEndDate, rightAllDay)):
        return (leftStartDate == rightStartDate) && (leftEndDate == rightEndDate) && (leftAllDay == rightAllDay)
    case let (.reminder(_, leftURL, _), .reminder(_, rightURL, _)):
        return leftURL == rightURL
    case let (.location(leftName, leftAddress), .location(rightName, rightAddress)):
        return (leftName == rightName) && (leftAddress == rightAddress)
    case let (.details(leftURL, leftDeets), .details(rightURL, rightDeets)):
        return (leftURL == rightURL) && (leftDeets == rightDeets)
    default:
        return false
    }
}
