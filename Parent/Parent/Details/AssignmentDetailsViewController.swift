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
import AssignmentKit
import TooLegit
import ReactiveCocoa
import SoPersistent
import EnrollmentKit
import Airwolf

extension EventDetailsViewModel {
    static func detailsForAssignment(baseURL: NSURL, observeeID: String, context: UIViewController) -> (assignment: Assignment) -> [EventDetailsViewModel] {
        return { assignment in
            var deets: [EventDetailsViewModel] = [
                .Info(name: assignment.name, submissionInfo: assignment.submittedVerboseText, submissionColor: assignment.submittedColor),
                .Reminder(date: assignment.scheduledReminder()?.fireDate, remindable: assignment, actionURL: Router.sharedInstance.assignmentDetailsRoute(studentID: observeeID, courseID: assignment.courseID, assignmentID: assignment.id), context: context),
            ]

            if let dueDate = assignment.due {
                let date: EventDetailsViewModel = .Date(start: dueDate, end: dueDate)
                deets.insert(date, atIndex: 1)
            }

            if assignment.details.characters.count > 0 {
                deets.append(.Details(baseURL: baseURL, deets: assignment.details))
            }

            return deets
        }
    }
}

class AssignmentDetailsViewController: Assignment.DetailViewController {
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

