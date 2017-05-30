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

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    case title(String)
    case startDate(Date)
    case endDate(Date)
    case details(URL, String)

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TitleCell")
        tableView.register(WhizzyWigTableViewCell.self, forCellReuseIdentifier: "WhizzyCell")
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .title(let name):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            cell.textLabel?.text = name
            return cell
        case .startDate(let startDate):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            cell.textLabel?.text = CalendarEventDetailViewModel.dateFormatter.string(from: startDate)
            return cell
        case .endDate(let endDate):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            cell.textLabel?.text = CalendarEventDetailViewModel.dateFormatter.string(from: endDate)
            return cell

        case .details(let baseURL, let deets):
            print(deets)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WhizzyCell", for: indexPath) as? WhizzyWigTableViewCell else { fatalError() }
            cell.whizzyWigView.loadHTMLString(deets, baseURL: baseURL)
            cell.cellSizeUpdated = { [weak tableView] _ in
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            return cell
        }
    }


    static func detailsForCalendarEvent(_ baseURL: URL, _ calendarEvent: CalendarEvent) -> [CalendarEventDetailViewModel] {
        return [
            .title(calendarEvent.title!),
            .startDate(calendarEvent.startAt!),
            .endDate(calendarEvent.endAt!),
            .details(baseURL, calendarEvent.htmlDescription ?? "")
        ]
    }
}

extension CalendarEventDetailViewModel: Equatable { }
func ==(lhs: CalendarEventDetailViewModel, rhs: CalendarEventDetailViewModel) -> Bool {
    switch (lhs, rhs) {
    case let (.title(leftTitle), .title(rightTitle)):
        return leftTitle == rightTitle
    case let (.startDate(leftStartDate), .startDate(rightStartDate)):
        return leftStartDate == rightStartDate
    case let (.endDate(leftEndDate), .endDate(rightEndDate)):
        return leftEndDate == rightEndDate
    case let (.details(leftURL, leftDeets), .details(rightURL, rightDeets)):
        return (leftURL == rightURL) && (leftDeets == rightDeets)
    default:
        return false
    }
}

import ReactiveSwift

class CalendarEventDeets: CalendarEventDetailViewController {
    var disposable: Disposable?

    init(session: Session, calendarEventID: String) throws {
        super.init()
        let observer = try CalendarEvent.observer(session, calendarEventID: calendarEventID)
        let refresher = try CalendarEvent.refresher(session, calendarEventID: calendarEventID)

        prepare(observer, refresher: refresher) { event in
            return CalendarEventDetailViewModel.detailsForCalendarEvent(session.baseURL, event)
        }

        disposable = observer.signal.map { $0.1 }
            .observeValues { calendarEvent in
                print(calendarEvent?.title)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
