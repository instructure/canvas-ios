//
//  MasteryPathAssignment+Collections.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 10/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import TooLegit

extension MasteryPathAssignment {
    public static func predicate(forAssignmentsInSet assignmentSetID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "assignmentSetID", assignmentSetID)
    }

    public static func allAssignmentsInSet(session: Session, assignmentSetID: String) throws -> FetchedCollection<MasteryPathAssignment> {
        let context = try session.soEdventurousManagedObjectContext()
        let frc = fetchedResults(predicate(forAssignmentsInSet: assignmentSetID), sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }
}
