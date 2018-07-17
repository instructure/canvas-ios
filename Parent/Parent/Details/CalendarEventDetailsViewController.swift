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

import ReactiveSwift

import CanvasCore

extension EventDetailsViewModel {
    static func detailsForCalendarEvent(_ baseURL: URL, studentID: String, context: UIViewController, calendarEvent: CalendarEvent) -> [EventDetailsViewModel] {
        var actionURL: URL = Router.sharedInstance.dashboardRoute()
        if let courseID = ContextID(canvasContext: calendarEvent.contextCode)?.id {
            actionURL = Router.sharedInstance.calendarEventDetailsRoute(studentID: studentID, courseID: courseID, calendarEventID: calendarEvent.id)
        }

        // Pass along a `Reminder` struct because it's unsafe to pass around the managed object
        // due to notification calls happening on different threads
        let remindable = Reminder(id: calendarEvent.id, title: calendarEvent.reminderTitle, body: calendarEvent.reminderBody, date: calendarEvent.defaultReminderDate)
        var vms: [EventDetailsViewModel] = [
            .info(name: calendarEvent.title ?? "", submissionInfo: calendarEvent.submittedVerboseText, submissionColor: calendarEvent.submittedColor),
            .reminder(remindable: remindable, actionURL: actionURL, context: context),
        ]

        if let startAt = calendarEvent.startAt, let endAt = calendarEvent.endAt {
            let dateVM: EventDetailsViewModel = .date(start: startAt, end: endAt, allDay: calendarEvent.allDay)
            vms.insert(dateVM, at: 1)
        }

        if calendarEvent.locationName?.isEmpty == false || calendarEvent.locationAddress?.isEmpty == false {
            let locationVM: EventDetailsViewModel = .location(locationName: calendarEvent.locationName, address: calendarEvent.locationAddress)
            vms.append(locationVM)
        }

        if let htmlDescription = calendarEvent.htmlDescription, !htmlDescription.isEmpty {
            vms.append(.details(baseURL: baseURL, deets: htmlDescription))
        }

        return vms
    }
}

class CalendarEventDetailsViewController: CalendarEventDetailViewController {
    var disposable: Disposable?
    let studentID: String

    init(session: Session, studentID: String, courseID: String, calendarEventID: String) throws {
        self.studentID = studentID
        super.init()
        let observer = try CalendarEvent.observer(session, studentID: studentID, calendarEventID: calendarEventID)
        let refresher = try CalendarEvent.refresher(session, studentID: studentID, calendarEventID: calendarEventID)
        
        let deets: (CalendarEvent) -> [EventDetailsViewModel] = { [weak self] event in
            guard let me = self else { return [] }
            return EventDetailsViewModel.detailsForCalendarEvent(session.baseURL, studentID: studentID, context: me, calendarEvent: event)
        }

        prepare(observer, refresher: refresher, detailsFactory: deets)
        disposable = observer.signal.map { $0.1 }
            .observeValues { _ in
        }

        session.enrollmentsDataSource(withScope: studentID)
            .producer(ContextID(id: courseID, context: .course))
            .observe(on: UIScheduler())
            .startWithValues { next in
            guard let course = next as? Course else { return }
            self.title = course.name
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
