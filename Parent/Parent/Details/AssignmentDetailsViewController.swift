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
import CanvasCore
import ReactiveSwift

extension EventDetailsViewModel {
    static func detailsForAssignment(_ baseURL: URL, observeeID: String, context: UIViewController) -> (Assignment) -> [EventDetailsViewModel] {
        return { assignment in
            // Pass along a `Reminder` struct because it's unsafe to pass around the managed object
            // due to notification calls happening on different threads
            let remindable = Reminder(id: assignment.id, title: assignment.reminderTitle, body: assignment.reminderBody, date: assignment.defaultReminderDate)
            var deets: [EventDetailsViewModel] = [
                .info(name: assignment.name, submissionInfo: assignment.submittedVerboseText, submissionColor: assignment.submittedColor),
                .reminder(remindable: remindable,
                          actionURL: Router.sharedInstance.assignmentDetailsRoute(studentID: observeeID,
                                                                                  courseID: assignment.courseID,
                                                                                  assignmentID: assignment.id),
                          context: context),
            ]

            if let dueDate = assignment.due {
                let date: EventDetailsViewModel = .date(start: dueDate, end: dueDate, allDay: false)
                deets.insert(date, at: 1)
            }

            if !assignment.details.isEmpty {
                deets.append(.details(baseURL: baseURL, deets: assignment.details))
            }

            return deets
        }
    }
}

class AssignmentDetailsViewController: AssignmentDetailViewController {
    var disposable: Disposable?
    @objc let courseID: String
    @objc let assignmentID: String

    @objc init(session: Session, studentID: String, courseID: String, assignmentID: String) throws {
        self.courseID = courseID
        self.assignmentID = assignmentID
        super.init()
        let observer = try Assignment.observer(session, studentID: studentID, courseID: courseID, assignmentID: assignmentID)
        let refresher = try Assignment.refresher(session, studentID: studentID, courseID: courseID, assignmentID: assignmentID)

        prepare(observer, refresher: refresher, detailsFactory: EventDetailsViewModel.detailsForAssignment(session.baseURL, observeeID: studentID, context: self))

        disposable = observer.signal.map { $0.1 }
            .observeValues { _ in
        }

        session.enrollmentsDataSource(withScope: studentID).producer(ContextID(id: courseID, context: .course)).observe(on: UIScheduler()).startWithValues { next in
            guard let course = next as? Course else { return }
            self.title = course.name
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
