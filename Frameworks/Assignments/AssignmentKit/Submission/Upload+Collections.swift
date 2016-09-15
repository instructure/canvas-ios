//
//  Upload+Collections.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import FileKit
import CoreData
import TooLegit
import SoLazy

extension Upload {
    public static func inProgress(session: Session) throws -> [Upload] {
        let context = try session.assignmentsManagedObjectContext()
        let request = NSFetchRequest(entityName: entityName(context))
        request.predicate = NSPredicate(format: "%K == nil", "terminatedAt")
        return try context.executeFetchRequest(request) as? [Upload] ?? []
    }

    public static func activeBackgroundSessionIdentifiers(session: Session) throws -> [String] {
        let context = try session.assignmentsManagedObjectContext()

        guard let entity = NSEntityDescription.entityForName(entityName(context), inManagedObjectContext: context) else {
            ❨╯°□°❩╯⌢"Failed to get Entity Description for Upload."
        }

        guard let property = entity.propertiesByName["backgroundSessionID"] else {
            ❨╯°□°❩╯⌢"Failed to get backgroundSessionID property."
        }

        let request = NSFetchRequest(entityName: entityName(context))
        request.resultType = .DictionaryResultType
        request.propertiesToFetch = [property]
        request.returnsDistinctResults = true

        guard let ids = try context.executeFetchRequest(request) as? [String] else {
            ❨╯°□°❩╯⌢"expected an array of String ids"
        }

        return ids
    }

    public static func inProgressFetch(session: Session, identifier: String) throws -> NSFetchRequest {
        let context = try session.assignmentsManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@ && %K == nil", "backgroundSessionID", identifier, "terminatedAt")
        return fetch(predicate, sortDescriptors: ["startedAt".ascending], inContext: context)
    }

    public static func inProgressFRC(session: Session, identifier: String) throws -> NSFetchedResultsController {
        let context = try session.assignmentsManagedObjectContext()
        let request = try inProgressFetch(session, identifier: identifier)
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
