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
import SoPersistent
import TooLegit
import CoreData

extension Tab {
    public static func collectionCacheKey(context: NSManagedObjectContext, contextID: ContextID) -> String {
        return cacheKey(context, [contextID.description])
    }

    public static func invalidateCache(session: Session, contextID: ContextID) throws {
        let context = try session.enrollmentManagedObjectContext()
        let key = collectionCacheKey(context, contextID: contextID)
        session.refreshScope.invalidateCache(key)
    }
    
    public static func collection(session: Session, contextID: ContextID) throws -> FetchedCollection<Tab> {
        let predicate = NSPredicate(format: "%K == %@ AND %K == NO", "rawContextID", contextID.canvasContextID, "hidden")
        let context = try session.enrollmentManagedObjectContext()
        let frc = Tab.fetchedResults(predicate, sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)

        return try FetchedCollection(frc: frc)
    }
    
    public static func shortcuts(session: Session, contextID: ContextID) throws -> FetchedCollection<Tab> {
        let predicate = NSPredicate(format: "%K == %@ AND %@ CONTAINS %K", "rawContextID", contextID.canvasContextID, ShortcutTabIDs, "id")
        let context = try session.enrollmentManagedObjectContext()
        let frc = Tab.fetchedResults(predicate, sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)
        
        return try FetchedCollection(frc: frc)
    }
    
    public static func refresher(session: Session, contextID: ContextID) throws -> Refresher {
        
        let remote = Tab.get(session, contextID: contextID)
        let context = try session.enrollmentManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "rawContextID", contextID.canvasContextID)
        let sync = syncSignalProducer(predicate, inContext: context, fetchRemote: remote)

        let key = collectionCacheKey(context, contextID: contextID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<Tab>
}
