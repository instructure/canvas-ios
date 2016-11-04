
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
import CalendarKit
import TooLegit
import ReactiveCocoa
import SoPersistent
import EnrollmentKit

extension EventDetailsViewModel {
    static func detailsForCalendarEvent(baseURL: NSURL, studentID: String, context: UIViewController) -> (calendarEvent: CalendarEvent) -> [EventDetailsViewModel] {
        return { calendarEvent in
            var actionURL: NSURL = Router.sharedInstance.dashboardRoute()
            if let courseID = ContextID(canvasContext: calendarEvent.contextCode)?.id {
                actionURL = Router.sharedInstance.calendarEventDetailsRoute(studentID: studentID, courseID: courseID, calendarEventID: calendarEvent.id)
            }

            var vms: [EventDetailsViewModel] = [
                .Info(name: calendarEvent.title ?? "", submissionInfo: calendarEvent.submittedVerboseText, submissionColor: calendarEvent.submittedColor),
                .Reminder(date: calendarEvent.scheduledReminder()?.fireDate, remindable: calendarEvent, actionURL: actionURL, context: context),
            ]

            if let startAt = calendarEvent.startAt, endAt = calendarEvent.endAt {
                let dateVM: EventDetailsViewModel = .Date(start: startAt, end: endAt)
                vms.insert(dateVM, atIndex: 1)
            }

            if calendarEvent.locationName != nil || calendarEvent.locationAddress != nil {
                let locationVM: EventDetailsViewModel = .Location(locationName: calendarEvent.locationName, address: calendarEvent.locationAddress)
                vms.append(locationVM)
            }

            if let htmlDescription = calendarEvent.htmlDescription {
                vms.append(.Details(baseURL: baseURL, deets: htmlDescription))
            }

            return vms
        }
    }
}

class CalendarEventDetailsViewController: CalendarEvent.DetailViewController {
    var disposable: Disposable?
    let studentID: String

    init(session: Session, studentID: String, courseID: String, calendarEventID: String) throws {
        self.studentID = studentID
        super.init()
        let observer = try CalendarEvent.observer(session, studentID: studentID, calendarEventID: calendarEventID)
        let refresher = try CalendarEvent.refresher(session, studentID: studentID, calendarEventID: calendarEventID)

        prepare(observer, refresher: refresher, detailsFactory: EventDetailsViewModel.detailsForCalendarEvent(session.baseURL, studentID: studentID, context: self))

        disposable = observer.signal.map { $0.1 }
            .observeNext { _ in
        }

        session.enrollmentsDataSource(withScope: studentID).producer(ContextID(id: courseID, context: .Course)).observeOn(UIScheduler()).startWithNext { next in
            guard let course = next as? Course else { return }
            self.title = course.name
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
