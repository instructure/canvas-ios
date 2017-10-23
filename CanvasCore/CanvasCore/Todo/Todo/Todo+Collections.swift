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
    
    

import UIKit

import CoreData



// ---------------------------------------------
// MARK: - Calendar Events collection for current user
// ---------------------------------------------
extension Todo {

    public static func allTodos(_ session: Session) throws -> FetchedCollection<Todo> {
        let predicate = NSPredicate(format: "%K == false", "done")
        let moc = try session.todosManagedObjectContext()
        return try FetchedCollection(frc:
            moc.fetchedResults(predicate, sortDescriptors: ["assignmentDueDate".ascending, "assignmentName".ascending])
        )
    }

    public static func refresher(_ session: Session) throws -> Refresher {
        let remote = try Todo.getTodos(session)
        let context = try session.todosManagedObjectContext()
        let sync = Todo.syncSignalProducer(inContext: context, fetchRemote: remote)
        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key, ttl: 1.minutes)
    }
}
