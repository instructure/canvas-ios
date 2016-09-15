//
//  Submission+Details.swift
//  Assignments
//
//  Created by Nathan Lambson on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import SoPersistent
import CoreData
import ReactiveCocoa

extension Submission {
    
    public static func detailsCacheKey(context: NSManagedObjectContext, courseID: String, assignmentID: String, userID: String) -> String {
        return cacheKey(context, [courseID, assignmentID, userID])
    }
    
    public static func predicate(courseID: String, assignmentID: String, userID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@ && %K == %@", "courseID", courseID, "assignmentID", assignmentID, "userID", userID)
    }
    
    public static func refreshSignalProducer(session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<[Submission], NSError> {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try Submission.getSubmission(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let pred = predicate(courseID, assignmentID: assignmentID, userID: session.user.id)
        return Submission.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
    }
    
    public static func observer(session: Session, courseID: String, assignmentID: String) throws -> ManagedObjectObserver<Submission> {
        let pred = predicate(courseID, assignmentID: assignmentID, userID: session.user.id)
        let context = try session.assignmentsManagedObjectContext()
        return try ManagedObjectObserver<Submission>(predicate: pred, inContext: context)
    }
}
