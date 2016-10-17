//
//  Upload+Details.swift
//  Assignments
//
//  Created by Nathan Armstrong on 10/12/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import FileKit
import SoPersistent
import TooLegit

extension Upload {
    public static func observer(session: Session, id: String) throws -> ManagedObjectObserver<Upload> {
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        let context = try session.assignmentsManagedObjectContext()
        return try ManagedObjectObserver(predicate: predicate, inContext: context)
    }
}
