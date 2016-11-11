//
//  ModuleItem+Progression.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import TooLegit

extension ModuleItem {
    public func next(session: Session) throws -> ModuleItem? {
        return try search(session, ascending: true)
    }

    public func previous(session: Session) throws -> ModuleItem? {
        return try search(session, ascending: false)
    }

    private func search(session: Session, ascending: Bool) throws -> ModuleItem? {
        let context = try session.soEdventurousManagedObjectContext()

        let higherPosition = NSPredicate(format: "%K > %f", "position", position)
        let lowerPosition = NSPredicate(format: "%K < %f", "position", position)
        let searchPosition = ascending ? higherPosition : lowerPosition
        let sameModule = ModuleItem.predicate(forItemsIn: moduleID)
        let notASubHeader = NSPredicate(format: "%K != %@", "contentType", ModuleItem.ContentType.subHeader.rawValue)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sameModule, searchPosition, notASubHeader])

        let sort = ascending ? "position".ascending : "position".descending

        let fetch = ModuleItem.fetch(predicate, sortDescriptors: [sort], inContext: context)
        let results: [ModuleItem] = try context.findAll(fromFetchRequest: fetch)
        return results.first
    }

    public func lockedBySequentialProgress(session: Session) throws -> Bool {
        let context = try session.soEdventurousManagedObjectContext()

        guard let module: Module = try context.findOne(withValue: moduleID, forKey: "id") else {
            return true
        }

        let prerequisiteModulesRequiringSequentialProgress: [Module] = try context.findAll(matchingPredicate: NSPredicate(format: "%K in %@ && %K == %@", "id", module.prerequisiteModuleIDs, "requireSequentialProgress", NSNumber(bool: true)))
        guard module.requireSequentialProgress || prerequisiteModulesRequiringSequentialProgress.any() else {
            return false
        }

        let incomplete = NSPredicate(format: "%K == %@", "completed", NSNumber(bool: false))

        let previous = NSPredicate(format: "%K == %@ && %K < %f", "moduleID", moduleID, "position", position)
        let previousIncompleteModuleItems: [ModuleItem] = try context.findAll(matchingPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: [incomplete, previous]))

        let prerequisite = NSPredicate(format: "%K in %@", "moduleID", module.prerequisiteModuleIDs)
        let prerequisiteIncompleteModuleItems: [ModuleItem] = try context.findAll(matchingPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: [incomplete, prerequisite]))

        return previousIncompleteModuleItems.any() || prerequisiteIncompleteModuleItems.any()
    }
}
