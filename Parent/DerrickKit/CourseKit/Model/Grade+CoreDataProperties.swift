//
//  Grade+CoreDataProperties.swift
//  Parent
//
//  Created by Brandon Pluim on 1/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Grade {

    @NSManaged var currentGrade: String?
    @NSManaged var currentScore: NSNumber?
    @NSManaged var finalGrade: String?
    @NSManaged var finalScore: NSNumber?
//    @NSManaged var course: Course?

}