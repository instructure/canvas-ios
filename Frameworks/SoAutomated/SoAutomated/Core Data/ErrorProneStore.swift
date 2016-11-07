//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
