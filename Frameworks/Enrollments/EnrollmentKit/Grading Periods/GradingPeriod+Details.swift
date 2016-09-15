//
//  GradingPeriod+Details.swift
//  Assignments
//
//  Created by Nathan Armstrong on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
import TooLegit
import SoPersistent

extension GradingPeriod {
    public static func observer(session: Session, id: String, courseID: String) throws -> ManagedObjectObserver<GradingPeriod> {
        let context = try session.enrollmentManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@ && %K == %@", "id", id, "courseID", courseID)
        return try ManagedObjectObserver(predicate: predicate, inContext: context)
    }
}
