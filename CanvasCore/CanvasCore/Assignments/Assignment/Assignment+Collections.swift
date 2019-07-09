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

import UIKit

import CoreData

import ReactiveSwift
import Marshal

extension Assignment {
    @objc public static func collectionCacheKey(_ context: NSManagedObjectContext, courseID: String, gradingPeriodID: String? = nil) -> String {
        return cacheKey(context, [courseID, gradingPeriodID].compactMap { $0 })
    }
    
    @objc public static func predicate(_ courseID: String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "courseID", courseID)
    }

    @objc public static func predicate(_ courseID: String, gradingPeriodID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "courseID", courseID, "gradingPeriodID", gradingPeriodID)
    }

    // Only meant to be used in conjunction with another predicate in a compound predicate
    @objc public static func predicate(withName name: String) -> NSPredicate {
        return NSPredicate(format: "%K LIKE[cd] %@", "name", name)
    }
    
    public static func collectionByDueStatus(_ session: Session, courseID: String, gradingPeriodID: String? = nil, filteredByName name: String? = nil) throws -> FetchedCollection<Assignment> {
        let predicate = gradingPeriodID.flatMap { Assignment.predicate(courseID, gradingPeriodID: $0) } ?? Assignment.predicate(courseID)
        let predicateFRD: NSPredicate
        if let name = name {
            let namePredicate = Assignment.predicate(withName: name)
            predicateFRD = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, namePredicate])
        } else {
            predicateFRD = predicate
        }
        let frc: NSFetchedResultsController<Assignment> = try session.assignmentsManagedObjectContext().fetchedResults(predicateFRD, sortDescriptors: ["rawDueStatus".ascending, "due".ascending, "name".ascending], sectionNameKeypath: "rawDueStatus")
        let titleFunction: (String?)->String? = { $0.flatMap { DueStatus(rawValue: $0) }?.description }
        return try FetchedCollection<Assignment>(frc: frc, titleForSectionTitle:titleFunction)
    }
    
    public static func collectionByDueDate(_ session: Session, courseID: String) throws -> FetchedCollection<Assignment> {
        let frc: NSFetchedResultsController<Assignment> = try session.assignmentsManagedObjectContext().fetchedResults(Assignment.predicate(courseID), sortDescriptors: ["due".ascending, "name".ascending, "id".ascending], sectionNameKeypath: nil)
        return try FetchedCollection(frc: frc)
    }
    
    public static func collectionByAssignmentGroup(_ session: Session, courseID: String, gradingPeriodID: String? = nil, filteredByName name: String? = nil) throws -> FetchedCollection<Assignment> {
        let predicate = gradingPeriodID.flatMap { Assignment.predicate(courseID, gradingPeriodID: $0) } ?? Assignment.predicate(courseID)
        let predicateFRD: NSPredicate
        if let name = name {
            let namePredicate = Assignment.predicate(withName: name)
            predicateFRD = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, namePredicate])
        } else {
            predicateFRD = predicate
        }
        let frc: NSFetchedResultsController<Assignment> = try session.assignmentsManagedObjectContext().fetchedResults(predicateFRD, sortDescriptors: ["assignmentGroup.position".ascending, "due".ascending, "name".ascending, "id".ascending], sectionNameKeypath: "assignmentGroupName")
        return try FetchedCollection(frc: frc)
    }

    public static func refreshSignalProducer(_ session: Session, courseID: String, gradingPeriodID: String?, invalidatingGradingPeriodIDs: [String], cacheKey: @escaping (String, String?) -> String) throws -> SignalProducer<Void, NSError> {
        let context = try session.assignmentsManagedObjectContext()

        // invalidate refresh cache for all other grading periods
        let invalidate = SignalProducer<String, NSError>(invalidatingGradingPeriodIDs).map { invalidGradingPeriodID in
            let key = cacheKey(courseID, invalidGradingPeriodID)
            session.refreshScope.invalidateCache(key, refresh: false)
            if gradingPeriodID != nil {
                session.refreshScope.invalidateCache(cacheKey(courseID, nil), refresh: false)
            }
        }
        .map { _ in () }

        // get all assignments
        let assignments = try Assignment.getAssignments(session, courseID: courseID)
        let assignmentsSync = Assignment.syncSignalProducer(predicate(courseID), inContext: context, fetchRemote: assignments) { assignment, _ in
            assignment.gradingPeriodID = nil
        }
        .map { _ in () }

        // get groups for grading period
        let groups = try AssignmentGroup.getAssignmentGroups(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
        let groupsSync = AssignmentGroup.syncSignalProducer(inContext: context, fetchRemote: groups) { group, json in
            try group.updateAssignments(json, inContext: context)
        }
        .map { _ in ()  }

        // concat because order matters
        return invalidate.concat(assignmentsSync).concat(groupsSync)
    }

    public static func refresher(_ session: Session, courseID: String, gradingPeriodID: String? = nil, invalidatingGradingPeriodIDs: [String] = []) throws -> Refresher {
        let context = try session.assignmentsManagedObjectContext()
        let sync = try refreshSignalProducer(session, courseID: courseID, gradingPeriodID: gradingPeriodID, invalidatingGradingPeriodIDs: invalidatingGradingPeriodIDs) { courseID, gradingPeriodID in
            return collectionCacheKey(context, courseID: courseID, gradingPeriodID: gradingPeriodID)
        }
        let key = collectionCacheKey(context, courseID: courseID, gradingPeriodID: gradingPeriodID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    @objc public static func invalidateCache(_ session: Session, courseID: String) throws {
        let context = try session.assignmentsManagedObjectContext()
        session.refreshScope.invalidateCache(collectionCacheKey(context, courseID: courseID), refresh: false)
        for gradingPeriodID in try GradingPeriod.gradingPeriodIDs(session, courseID: courseID, excludingGradingPeriodID: nil) {
            session.refreshScope.invalidateCache(collectionCacheKey(context, courseID: courseID, gradingPeriodID: gradingPeriodID), refresh: false)
        }
    }
}
