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
    
    

import UIKit
import CalendarKit
import WhizzyWig
import SoPersistent
import TooLegit

enum CalendarEventDetailViewModel: TableViewCellViewModel {

    static var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter
    }()

    case Title(String)
    case StartDate(NSDate)
    case EndDate(NSDate)
    case Details(NSURL, String)

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .None
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TitleCell")
        tableView.registerClass(WhizzyWigTableViewCell.self, forCellReuseIdentifier: "WhizzyCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch self {
        case .Title(let name):
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath)
            cell.textLabel?.text = name
            return cell
        case .StartDate(let startDate):
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath)
            cell.textLabel?.text = CalendarEventDetailViewModel.dateFormatter.stringFromDate(startDate)
            return cell
        case .EndDate(let endDate):
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath)
            cell.textLabel?.text = CalendarEventDetailViewModel.dateFormatter.stringFromDate(endDate)
            return cell

        case .Details(let baseURL, let deets):
            print(deets)
            guard let cell = tableView.dequeueReusableCellWithIdentifier("WhizzyCell", forIndexPath: indexPath) as? WhizzyWigTableViewCell else { fatalError() }
            cell.whizzyWigView.loadHTMLString(deets, baseURL: baseURL)
            cell.cellSizeUpdated = { [weak tableView] _ in
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            return cell
        }
    }


    static func detailsForCalendarEvent(baseURL: NSURL)(calendarEvent: CalendarEvent) -> [CalendarEventDetailViewModel] {
        return [
            .Title(calendarEvent.title!),
            .StartDate(calendarEvent.startAt!),
            .EndDate(calendarEvent.endAt!),
            .Details(baseURL, calendarEvent.htmlDescription ?? "")
        ]
    }
}

extension CalendarEventDetailViewModel: Equatable { }
func ==(lhs: CalendarEventDetailViewModel, rhs: CalendarEventDetailViewModel) -> Bool {
    switch (lhs, rhs) {
    case let (.Title(leftTitle), .Title(rightTitle)):
        return leftTitle == rightTitle
    case let (.StartDate(leftStartDate), .StartDate(rightStartDate)):
        return leftStartDate == rightStartDate
    case let (.EndDate(leftEndDate), .EndDate(rightEndDate)):
        return leftEndDate == rightEndDate
    case let (.Details(leftURL, leftDeets), .Details(rightURL, rightDeets)):
        return (leftURL == rightURL) && (leftDeets == rightDeets)
    default:
        return false
    }
}

import ReactiveCocoa

class CalendarEventDeets: CalendarEvent.DetailViewController {
    var disposable: Disposable?

    init(session: Session, calendarEventID: String) throws {
        super.init()
        let observer = try CalendarEvent.observer(session, calendarEventID: calendarEventID)
        let refresher = try CalendarEvent.refresher(session, calendarEventID: calendarEventID)

        prepare(observer, refresher: refresher, detailsFactory: CalendarEventDetailViewModel.detailsForCalendarEvent(session.baseURL))

        disposable = observer.signal.map { $0.1 }
            .observeNext { calendarEvent in
                print(calendarEvent?.title)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}