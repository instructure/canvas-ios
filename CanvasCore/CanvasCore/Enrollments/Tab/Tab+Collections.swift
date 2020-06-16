//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation


import CoreData

extension Tab {
    public static func collectionCacheKey(context: NSManagedObjectContext, contextID: Context) -> String {
        return cacheKey(context, [contextID.canvasContextID])
    }

    public static func invalidateCache(session: Session, contextID: Context) throws {
        let context = try session.enrollmentManagedObjectContext()
        let key = collectionCacheKey(context: context, contextID: contextID)
        session.refreshScope.invalidateCache(key)
    }
    
    public static func collection(_ session: Session, contextID: Context) throws -> FetchedCollection<Tab> {
        let predicate = NSPredicate(format: "%K == %@ AND %K == NO", "rawContextID", contextID.canvasContextID, "hidden")
        let context = try session.enrollmentManagedObjectContext()
        return try FetchedCollection(frc:
            context.fetchedResults(predicate, sortDescriptors: ["position".ascending])
        )
    }
    
    public static func shortcuts(_ session: Session, contextID: Context) throws -> FetchedCollection<Tab> {
        let predicate = NSPredicate(format: "%K == %@ AND %@ CONTAINS %K", "rawContextID", contextID.canvasContextID, ShortcutTabIDs, "id")
        let context = try session.enrollmentManagedObjectContext()
        return try FetchedCollection(frc:
            context.fetchedResults(predicate, sortDescriptors: ["position".ascending])
        )
    }
    
    public static func refresher(_ session: Session, contextID: Context) throws -> Refresher {
        
        let remote = Tab.get(session, contextID: contextID)
        let context = try session.enrollmentManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "rawContextID", contextID.canvasContextID)
        let sync = syncSignalProducer(predicate, inContext: context, fetchRemote: remote)

        let key = collectionCacheKey(context: context, contextID: contextID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}
