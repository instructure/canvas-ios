//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
