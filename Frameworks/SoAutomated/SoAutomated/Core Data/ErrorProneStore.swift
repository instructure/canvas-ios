//
//  ErrorProneStore.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 3/8/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import Foundation
import CoreData

let ErrorProneStoreType = "SoAutomated.ErrorProneStore"

class ErrorProneStore: NSIncrementalStore {
    enum ErrorProneStoreError: ErrorType {
        case Mwahaha
    }

    func throwError() throws {
        throw ErrorProneStoreError.Mwahaha
    }

    override func loadMetadata() throws {
        let metadata = [NSStoreTypeKey: ErrorProneStoreType, NSStoreUUIDKey: ""]
        self.metadata = metadata
    }

    override func executeRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext?) throws -> AnyObject {
        try throwError()
        return NSObject()
    }

    override func newValueForRelationship(relationship: NSRelationshipDescription, forObjectWithID objectID: NSManagedObjectID, withContext context: NSManagedObjectContext?) throws -> AnyObject {
        try throwError()
        return NSObject()
    }

    override func newValuesForObjectWithID(objectID: NSManagedObjectID, withContext context: NSManagedObjectContext) throws -> NSIncrementalStoreNode {
        try throwError()
        return NSIncrementalStoreNode(objectID: NSManagedObjectID(), withValues: [:], version: 1)
    }

    override func obtainPermanentIDsForObjects(array: [NSManagedObject]) throws -> [NSManagedObjectID] {
        try throwError()
        return []
    }
}
