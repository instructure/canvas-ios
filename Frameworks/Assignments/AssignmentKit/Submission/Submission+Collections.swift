//
//  Submission+Collections.swift
//  Assignments
//
//  Created by Derrick Hathaway on 10/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent
import ReactiveCocoa
import Result
import TooLegit

extension Submission {
    public static func studentSubmissionsRefresher(session: Session, courseID: String, assignmentID: String) throws -> Refresher {
        let context = try session.assignmentsManagedObjectContext()
        
        let get = try Submission.getStudentSubmissions(session, courseID: courseID, assignmentID: assignmentID)
        let sync = Submission.syncSignalProducer(inContext: context, fetchRemote: get)
        
        let key = cacheKey(context, [courseID, assignmentID, "all_students"])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func studentSubmissionsCollection(session: Session, courseID: String, assignmentID: String) throws -> FetchedCollection<Submission> {
        let context = try session.assignmentsManagedObjectContext()
        
        let predicate = NSPredicate(format: "%K == %@", "assignmentID", assignmentID)
        let frc = Submission.fetchedResults(predicate, sortDescriptors: ["submittedAt".ascending, "id".ascending], inContext: context)
        
        return try FetchedCollection(frc: frc)
    }
}
