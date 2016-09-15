//
//  Student+Details.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SoPersistent
import CoreData
import ReactiveCocoa

extension Student {
    public static func predicate(withStudentID studentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", studentID)
    }

    public static func observer(session: Session, studentID: String) throws -> ManagedObjectObserver<Student> {
        let pred = predicate(withStudentID: studentID)
        let context = try session.airwolfManagedObjectContext()
        return try ManagedObjectObserver<Student>(predicate: pred, inContext: context)
    }
}