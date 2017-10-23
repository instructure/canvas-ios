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
    
    

import Foundation

import CoreData

import CanvasCore

extension Student {
    public static func countOfObservedStudents(_ session: Session) throws -> Int {
        let context = try session.airwolfManagedObjectContext()
        let studentsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName(context))
        studentsFetch.predicate = NSPredicate(format: "%K == %@", "parentID", session.user.id)
        let count = try context.count(for: studentsFetch)
        return count
    }

    public static func countOfObservedStudentsObserver(_ session: Session, countUpdated: @escaping (Int)->Void) throws -> ManagedObjectCountObserver<Student> {
        let observer = ManagedObjectCountObserver<Student>(predicate: NSPredicate(format: "%K == %@", "parentID", session.user.id), inContext: try session.airwolfManagedObjectContext(), objectCountUpdated: countUpdated)
        return observer
    }

    public static func observedStudentsCollection(_ session: Session) throws -> FetchedCollection<Student> {
        let predicate = NSPredicate(format: "%K == %@", "parentID", session.user.id)
        let context = try session.airwolfManagedObjectContext()

        return try FetchedCollection<Student>(frc:
            context.fetchedResults(predicate, sortDescriptors: ["sortableName".ascending])
        )
    }

    public static func observedStudentsSyncProducer(_ session: Session) throws -> Student.ModelPageSignalProducer {
        let remote = try Student.getStudents(session, parentID: session.user.id)
        return Student.syncSignalProducer(inContext: try session.airwolfManagedObjectContext(), fetchRemote: remote)
    }

    public static func observedStudentsRefresher(_ session: Session) throws -> Refresher {
        let sync = try observedStudentsSyncProducer(session)
        let context = try session.airwolfManagedObjectContext()
        let key = self.cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}
