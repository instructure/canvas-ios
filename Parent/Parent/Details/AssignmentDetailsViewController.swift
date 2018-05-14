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

extension EventDetailsViewModel {
    static func detailsForAssignment(_ baseURL: URL, observeeID: String, context: UIViewController) -> (Assignment) -> [EventDetailsViewModel] {
        return { assignment in
            var deets: [EventDetailsViewModel] = [
                .info(name: assignment.name, submissionInfo: assignment.submittedVerboseText, submissionColor: assignment.submittedColor),
                .reminder(date: assignment.scheduledReminder()?.fireDate, remindable: assignment, actionURL: Router.sharedInstance.assignmentDetailsRoute(studentID: observeeID, courseID: assignment.courseID, assignmentID: assignment.id), context: context),
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
    let courseID: String
    let assignmentID: String

    init(session: Session, studentID: String, courseID: String, assignmentID: String) throws {
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

