//
//  MasteryPathsItem.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent

public class MasteryPathsItem: ModuleItem {
    @NSManaged internal (set) public var locked: Bool
    @NSManaged internal (set) public var moduleItemID: String
    @NSManaged internal (set) public var selectedSetID: String?
    @NSManaged internal (set) public var assignmentSets: NSSet

    func addAssignmentSetObject(object: MasteryPathAssignmentSet) {
        let sets = self.mutableSetValueForKey("assignmentSets")
        sets.addObject(object)
    }

    func removeAssignmentSetObject(object: MasteryPathAssignmentSet) {
        let sets = self.mutableSetValueForKey("assignmentSets")
        sets.removeObject(object)
    }
}
