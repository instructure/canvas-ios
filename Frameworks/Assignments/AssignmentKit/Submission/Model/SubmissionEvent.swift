//
//  SubmissionEvent.swift
//  Assignments
//
//  Created by Derrick Hathaway on 1/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
import SoPersistent

public class SubmissionEvent: NSManagedObject {
    @NSManaged var date: NSDate

    @NSManaged var assignment: Assignment?
}
