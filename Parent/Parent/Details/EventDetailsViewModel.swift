//
//  EventDetailsViewModel.swift
//  Parent
//
//  Created by Ben Kraus on 3/22/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import SoPretty
import SoPersistent
import WhizzyWig

private let TitleCellReuseIdentifier = "TitleCell"
private let ReminderCellReuseIdentifier = "ReminderCell"
private let DateCellReuseIdentifier = "DueDateCell"
private let LocationCellReuseIdentifier = "LocationCell"
private let DetailsCellReuseIdentifier = "DetailsCell"

enum EventDetailsViewModel: TableViewCellViewModel {

    case Info(name: String, submissionInfo: String?, submissionColor: UIColor?)
    case Reminder(date: NSDate?, remindable: Remindable, actionURL: NSURL, context: UIViewController)
    case Date(start: NSDate, end: NSDate)
    case Location(locationName: String?, address: String?)
    case Details(baseURL: NSURL, deets: String)

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 52.0
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "DetailsInfoCell", bundle: nil), forCellReuseIdentifier: TitleCellReuseIdentifier)
        tableView.registerNib(UINib(nibName: "DetailsReminderCell", bundle: nil), forCellReuseIdentifier: ReminderCellReuseIdentifier)
        tableView.registerNib(UINib(nibName: "DetailsDateCell", bundle: nil), forCellReuseIdentifier: DateCellReuseIdentifier)
        tableView.registerNib(UINib(nibName: "DetailsLocationCell", bundle: nil), forCellReuseIdentifier: LocationCellReuseIdentifier)
        tableView.registerClass(DetailsDescriptionCell.self, forCellReuseIdentifier: DetailsCellReuseIdentifier)
    }

    static var dateFormatter: NSDateIntervalFormatter = {
        let dateFormatter = NSDateIntervalFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch self {
        case .Info(let name, let submissionInfo, let submissionColor):
            guard let cell = tableView.dequeueReusableCellWithIdentifier(TitleCellReuseIdentifier, forIndexPath: indexPath) as? DetailsInfoCell else { fatalError() }
            cell.titleLabel.text? = name
            cell.submissionLabel.text = submissionInfo ?? ""
            cell.submissionLabel.backgroundColor = submissionColor
            cell.setShowsSubmissionInfo(submissionInfo != nil && submissionInfo!.characters.count > 0)
            return cell

        case .Date(let startDate, let endDate):
            guard let cell = tableView.dequeueReusableCellWithIdentifier(DateCellReuseIdentifier, forIndexPath: indexPath) as? DetailsDateCell else { fatalError() }

            let str = String(format: NSLocalizedString("%@", comment: "Label indicating when the event takes place"), EventDetailsViewModel.dateFormatter.stringFromDate(startDate, toDate: endDate))
            cell.dateLabel.text = str

            return cell

        case .Reminder(let date, let remindable, let actionURL, let context):
            guard let cell = tableView.dequeueReusableCellWithIdentifier(ReminderCellReuseIdentifier, forIndexPath: indexPath) as? DetailsReminderCell else { fatalError() }
            cell.toggle.on = (date != nil)
            cell.setExpanded((date != nil))
            if let date = date {
                cell.dateLabel.text = DetailsReminderCell.dateFormatter.stringFromDate(date)
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
                        cell.dateLabel.text = DetailsReminderCell.dateFormatter.stringFromDate(date)
                        cell.setExpanded(true)
                        tableView?.beginUpdates()
                        tableView?.endUpdates()
                    }
                    vc.datePicker.date = max(NSDate(), remindable.defaultReminderDate) // never let it go into the past
                    vc.datePicker.minimumDate = NSDate()
                    let nav = SmallModalNavigationController(rootViewController: vc)
                    nav.navigationBar.barStyle = .Black
                    nav.navigationBar.barTintColor = UIColor.whiteColor()
                    context.presentViewController(nav, animated: true, completion: nil)
                } else {
                    remindable.cancelReminder()
                    cell.dateLabel.text = ""
                    cell.setExpanded(false)
                    tableView?.beginUpdates()
                    tableView?.endUpdates()
                }
            }
            return cell
        case .Location(let locationName, let address):
            guard let cell = tableView.dequeueReusableCellWithIdentifier(LocationCellReuseIdentifier, forIndexPath: indexPath) as? DetailsLocationCell else { fatalError() }
            let components = [locationName, address].flatMap { $0 }
            cell.locationLabel.text = components.joinWithSeparator("\n")
            return cell

        case .Details(let baseURL, let deets):
            guard let cell = tableView.dequeueReusableCellWithIdentifier(DetailsCellReuseIdentifier, forIndexPath: indexPath) as? WhizzyWigTableViewCell else { fatalError() }
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
    case let (.Info(leftName, leftSubmissionInfo, _), .Info(rightName, rightSubmissionInfo, _)):
        return leftName == rightName && leftSubmissionInfo == rightSubmissionInfo
    case let (.Date(leftStartDate, leftEndDate), .Date(rightStartDate, rightEndDate)):
        return (leftStartDate == rightStartDate) && (leftEndDate == rightEndDate)
    case let (.Reminder(leftDate, _, _, _), .Reminder(rightDate, _, _, _)):
        return leftDate == rightDate
    case let (.Location(leftName, leftAddress), .Location(rightName, rightAddress)):
        return (leftName == rightName) && (leftAddress == rightAddress)
    case let (.Details(leftURL, leftDeets), .Details(rightURL, rightDeets)):
        return (leftURL == rightURL) && (leftDeets == rightDeets)
    default:
        return false
    }
}
