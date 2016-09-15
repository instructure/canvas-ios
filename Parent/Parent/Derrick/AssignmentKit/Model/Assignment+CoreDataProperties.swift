//
//  Assignment+CoreDataProperties.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/28/15.
//  Copyright © 2015 Instructure. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Assignment {

    @NSManaged var id: Int64
    @NSManaged var courseID: Int64
    @NSManaged var name: String
    @NSManaged var due: NSDate?
    @NSManaged var details: String
    @NSManaged var rawActivityURL: String?
    @NSManaged var rawKind: String
}
