//
//  Course+Collections.swift
//  Enrollments
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy
import Marshal

// ---------------------------------------------
// MARK: - Courses current user
// ---------------------------------------------
extension Course {
    public static func allCoursesCollection(session: Session) throws -> FetchedCollection<Course> {
        let context = try session.enrollmentManagedObjectContext()
        let frc = Course.fetchedResults(nil, sortDescriptors: ["name".ascending, "id".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }

    public static func favoritesCollection(session: Session) throws -> FetchedCollection<Course> {
        let favorites = NSPredicate(format: "%K == YES", "isFavorite")
        let context = try session.enrollmentManagedObjectContext()
        let frc = Course.fetchedResults(favorites, sortDescriptors: ["name".ascending, "id".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }

    public static func collectionByStudent(session: Session, studentID: String) throws -> FetchedCollection<Course> {
        let context = try session.enrollmentManagedObjectContext(studentID)
        let frc = Course.fetchedResults(nil, sortDescriptors: ["name".ascending, "id".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }

    public static func refresher(session: Session) throws -> Refresher {
        let remote = try Course.getAllCourses(session)
        let context = try session.enrollmentManagedObjectContext()
        let sync = Course.syncSignalProducer(inContext: context, fetchRemote: remote)
            .map({_ in })
        
        let colors = Enrollment.syncFavoriteColors(session, inContext: context)
        
        let key = cacheKey(context)
        
        return SignalProducerRefresher(refreshSignalProducer: sync.concat(colors), scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<Course>

    public typealias CollectionViewController = FetchedCollectionViewController<Course>
}
