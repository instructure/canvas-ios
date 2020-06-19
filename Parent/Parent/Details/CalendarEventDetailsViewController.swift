//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import ReactiveSwift
import Core
import CanvasCore

extension EventDetailsViewModel {
    static func detailsForCalendarEvent(_ baseURL: URL, studentID: String, context: UIViewController, calendarEvent: CalendarEvent) -> [EventDetailsViewModel] {
        var actionURL = URL(string: "/courses")!
        if let courseID = Context(canvasContextID: calendarEvent.contextCode)?.id {
            actionURL = URL(string: "/courses/\(courseID)/calendar_events/\(calendarEvent.id)")!
        }

        // Pass along a `Reminder` struct because it's unsafe to pass around the managed object
        // due to notification calls happening on different threads
        let remindable = Reminder(id: calendarEvent.id, title: calendarEvent.reminderTitle, body: calendarEvent.reminderBody, date: calendarEvent.defaultReminderDate)
        var vms: [EventDetailsViewModel] = [
            .info(name: calendarEvent.title ?? "", submissionInfo: calendarEvent.submittedVerboseText, submissionColor: calendarEvent.submittedColor),
            .reminder(remindable: remindable, studentID: studentID, actionURL: actionURL, context: context),
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
    @objc let studentID: String

    @objc init(session: Session, studentID: String, courseID: String? = nil, calendarEventID: String) throws {
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

        if let courseID = courseID {
            session.enrollmentsDataSource(withScope: studentID)
                .producer(Context(.course, id: courseID))
                .observe(on: UIScheduler())
                .startWithValues { next in
                    guard let course = next as? CanvasCore.Course else { return }
                    self.title = course.name
            }
        } else {
            title = NSLocalizedString("Calendar Event", comment: "")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scheme = ColorScheme.observee(studentID)
        navigationController?.navigationBar.useContextColor(scheme.color)
    }
}
