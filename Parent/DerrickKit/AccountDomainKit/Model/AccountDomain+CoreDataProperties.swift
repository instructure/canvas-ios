//
//  AccountDomain+CoreDataProperties.swift
//  Assignments
//
//  Created by Brandon Pluim on 1/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension AccountDomain {

    @NSManaged var domain: String
    @NSManaged var name: String
    
}
