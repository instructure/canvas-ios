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

import ReactiveSwift

import CoreData


extension Grade {
    @objc static func coursePredicate(_ courseID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "course.id", courseID)
    }

    @objc static func gradingPeriodPredicate(_ gradingPeriodID: String?) -> NSPredicate {
        guard let gradingPeriodID = gradingPeriodID else {
            return NSPredicate(format: "%K == nil", "gradingPeriodID")
        }
        return NSPredicate(format: "%K == %@", "gradingPeriodID", gradingPeriodID)
    }

    @objc static func predicate(_ courseID: String, gradingPeriodID: String?) -> NSPredicate {
        let gradingPeriod = Grade.gradingPeriodPredicate(gradingPeriodID)
        let course = Grade.coursePredicate(courseID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [gradingPeriod, course])
    }

    public static func collectionByCourseID(_ session: Session, courseID: String) throws -> FetchedCollection<Grade> {
        let context = try session.enrollmentManagedObjectContext()
        return try FetchedCollection(frc:
            context.fetchedResults(coursePredicate(courseID), sortDescriptors: [])
        )
    }

    public static func refreshSignalProducer(_ session: Session, courseID: String, gradingPeriodID: String?) throws -> SignalProducer<[Grade], NSError> {
        let context = try session.enrollmentManagedObjectContext()
        let remote = try Grade.getGrades(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
        let local = predicate(courseID, gradingPeriodID: gradingPeriodID)
        return Grade.syncSignalProducer(local, inContext: context, fetchRemote: remote)
    }
}
