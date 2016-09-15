//
//  Course+CoreDataProperties.swift
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

extension Course {

    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var code: String
    @NSManaged var startAt: NSDate?
    @NSManaged var endAt: NSDate?
    @NSManaged var isFavorite: Bool
    @NSManaged var hideFinalGrades: Bool
    @NSManaged var rawDefaultView: String
    @NSManaged var rawRoles: Int64
//    @NSManaged var grade: Grade?

}
