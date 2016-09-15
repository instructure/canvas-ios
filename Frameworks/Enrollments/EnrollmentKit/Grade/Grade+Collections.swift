//
//  EnrollmentGrade+Collections.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/13/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import ReactiveCocoa
import TooLegit
import CoreData
import SoPersistent

extension Grade {
    static func coursePredicate(courseID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "course.id", courseID)
    }

    static func gradingPeriodPredicate(gradingPeriodID: String?) -> NSPredicate {
        guard let gradingPeriodID = gradingPeriodID else {
            return NSPredicate(format: "%K == nil", "gradingPeriodID")
        }
        return NSPredicate(format: "%K == %@", "gradingPeriodID", gradingPeriodID)
    }

    static func predicate(courseID: String, gradingPeriodID: String?) -> NSPredicate {
        let gradingPeriod = Grade.gradingPeriodPredicate(gradingPeriodID)
        let course = Grade.coursePredicate(courseID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [gradingPeriod, course])
    }

    public static func collectionByCourseID(session: Session, courseID: String) throws -> FetchedCollection<Grade> {
        let context = try session.enrollmentManagedObjectContext()
        let frc = try fetchedResults(coursePredicate(courseID), sortDescriptors: [], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }

    public static func refreshSignalProducer(session: Session, courseID: String, gradingPeriodID: String?) throws -> SignalProducer<[Grade], NSError> {
        let context = try session.enrollmentManagedObjectContext()
        let remote = try Grade.getGrades(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
        let local = predicate(courseID, gradingPeriodID: gradingPeriodID)
        return Grade.syncSignalProducer(local, inContext: context, fetchRemote: remote)
    }
}
