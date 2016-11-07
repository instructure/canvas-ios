//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
