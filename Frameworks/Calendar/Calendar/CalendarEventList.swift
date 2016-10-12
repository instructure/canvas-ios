//
//  CalendarList.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import CalendarKit
import SoPersistent
import TooLegit
import SoLazy

struct CalendarEventViewModel: TableViewCellViewModel {
    static var subtitleDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter
    }()

    static let reuseIdentifier = "CalendarEventCell"
    static let nibName = "CalendarEventCell"

    let name: String
    let subtitle: String

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: CalendarEventViewModel.nibName, bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: CalendarEventViewModel.reuseIdentifier)
    }
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CalendarEventViewModel.reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = subtitle
        return cell
    }

    init(calendarEvent: CalendarEvent) {
        name = calendarEvent.title ?? ""
        subtitle = calendarEvent.htmlDescription ?? ""
    }
}



class CalendarEventList: CalendarEvent.TableViewController {

    let session: Session

    init(session: Session, startDate: NSDate, endDate: NSDate, contextCodes: [String]) throws {
        self.session = session
        super.init()

        let collection = try CalendarEvent.collectionByDueDate(session, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        let refresher = try CalendarEvent.refresher(session, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        prepare(collection, refresher: refresher, viewModelFactory: CalendarEventViewModel.init)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let calendarEvent = collection[indexPath]
        do {
            let deets = try CalendarEventDeets(session: session, calendarEventID: calendarEvent.id)
            navigationController?.pushViewController(deets, animated: true)
        } catch let e as NSError {
            e.report(alertUserFrom: self)
        }
    }
}
