//
//  Student+Collections.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import CoreData
import SoPersistent
import SoLazy

extension Student {
    public static func countOfObservedStudents(session: Session) throws -> Int {
        let context = try session.airwolfManagedObjectContext()
        let studentsFetch = Student.fetch(NSPredicate(format: "%K == %@", "parentID", session.user.id), sortDescriptors: nil, inContext: context)
        let count = try context.countForFetchRequest(studentsFetch)
        return count
    }

    public static func countOfObservedStudentsObserver(session: Session, countUpdated: (Int)->Void) throws -> ManagedObjectCountObserver<Student> {
        let observer = ManagedObjectCountObserver<Student>(predicate: NSPredicate(format: "%K == %@", "parentID", session.user.id), inContext: try session.airwolfManagedObjectContext(), objectCountUpdated: countUpdated)
        return observer
    }

    public static func observedStudentsCollection(session: Session) throws -> FetchedCollection<Student> {
        let predicate = NSPredicate(format: "%K == %@", "parentID", session.user.id)
        let frc = Student.fetchedResults(predicate, sortDescriptors: ["sortableName".ascending], sectionNameKeypath: nil, inContext: try session.airwolfManagedObjectContext())

        return try FetchedCollection<Student>(frc: frc)
    }

    public static func observedStudentsSyncProducer(session: Session) throws -> Student.ModelPageSignalProducer {
        let remote = try Student.getStudents(session, parentID: session.user.id)
        return Student.syncSignalProducer(inContext: try session.airwolfManagedObjectContext(), fetchRemote: remote)
    }

    public static func observedStudentsRefresher(session: Session) throws -> Refresher {
        let sync = try observedStudentsSyncProducer(session)
        let context = try session.airwolfManagedObjectContext()
        let key = self.cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<Student>
}
