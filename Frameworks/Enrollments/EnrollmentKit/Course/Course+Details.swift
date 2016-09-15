//
//  Course+Details.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/19/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import SoPersistent
import TooLegit

extension Course {
    public static func observer(session: Session, courseID: String) throws -> ManagedObjectObserver<Course> {
        let context = try session.enrollmentManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "id", courseID)
        return try ManagedObjectObserver(predicate: predicate, inContext: context)
    }
}
