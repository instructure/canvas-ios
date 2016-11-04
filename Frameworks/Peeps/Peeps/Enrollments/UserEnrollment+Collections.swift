//
//  Enrollment+Collections.swift
//  Peeps
//
//  Created by Derrick Hathaway on 10/12/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import TooLegit
import SoPersistent

extension UserEnrollment {
    public static func refresher(enrolledIn context: ContextID, for session: Session) throws -> Refresher {
        let moc = try session.peepsManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "contextID", context.canvasContextID)
        let refreshProducer = UserEnrollment.syncSignalProducer(predicate, inContext: moc, fetchRemote: try User.getUsers(context, session: session)) { enrollment, _ in
            enrollment.contextID = context
        }
        
        let key = cacheKey(moc, [context.canvasContextID])
        return SignalProducerRefresher(refreshSignalProducer: refreshProducer, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func collection(enrolledIn contextID: ContextID, as roles: UserEnrollmentRoles = [], for session: Session) throws -> FetchedCollection<UserEnrollment> {
        
        let predicate: NSPredicate
        if !roles.isEmpty {
            predicate = NSPredicate(format: "%K == %@ && (%K & %@) > 0", "contextID", contextID.canvasContextID, "roles", NSNumber(int: roles.rawValue))
        } else {
            predicate = NSPredicate(format: "%K == %@", "contextID", contextID.canvasContextID)
        }
        
        let frc = UserEnrollment.fetchedResults(predicate, sortDescriptors: ["user.sortableName".ascending], sectionNameKeypath: nil, propertiesToFetch: ["user"], inContext: try session.peepsManagedObjectContext())
        
        return try FetchedCollection(frc: frc)
    }
}
