//
//  SubmissionFile.swift
//  Assignments
//
//  Created by Derrick Hathaway on 1/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
import SoPersistent
import FileKit


class SubmissionFile: NSManagedObject {
    @NSManaged var fileID: String
    @NSManaged var submission: Submission
    @NSManaged var file: File
}

