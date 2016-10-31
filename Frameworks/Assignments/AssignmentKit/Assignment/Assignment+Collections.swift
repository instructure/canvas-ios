//
//  Assignment+Collections.swift
//  Assignments
//
//  Created by Derrick Hathaway on 3/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy
import ReactiveCocoa
import Marshal

extension Assignment {
    
    static func collectionCacheKey(context: NSManagedObjectContext, courseID: String, gradingPeriodID: String? = nil) -> String {
        return cacheKey(context, [courseID, gradingPeriodID].flatMap { $0 })
    }
    
    public static func predicate(courseID: String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "courseID", courseID)
    }

    public static func predicate(courseID: String, gradingPeriodID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "courseID", courseID, "gradingPeriodID", gradingPeriodID)
    }

    public static func predicate(courseID: String, name: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K LIKE[cd] %@", "courseID", courseID, "name", name)
    }
    
    public static func predicate(courseID: String, gradingPeriodID: String, name: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@ && %K LIKE[cd] %@", "courseID", courseID, "gradingPeriodID", gradingPeriodID, "name", name)
    }
    
    public static func collectionByDueStatus(session: Session, courseID: String, gradingPeriodID: String? = nil) throws -> FetchedCollection<Assignment> {
        let predicate = gradingPeriodID.flatMap { Assignment.predicate(courseID, gradingPeriodID: $0) } ?? Assignment.predicate(courseID)
        let frc = Assignment.fetchedResults(predicate, sortDescriptors: ["rawDueStatus".ascending, "due".ascending, "name".ascending], sectionNameKeypath: "rawDueStatus", inContext: try session.assignmentsManagedObjectContext())
        let titleFunction: String?->String? = { $0.flatMap { DueStatus(rawValue: $0) }?.description }
        return try FetchedCollection<Assignment>(frc: frc, titleForSectionTitle:titleFunction)
    }
    
    public static func collectionByDueDate(session: Session, courseID: String) throws -> FetchedCollection<Assignment> {
        let frc = Assignment.fetchedResults(Assignment.predicate(courseID), sortDescriptors: ["due".ascending, "name".ascending, "id".ascending], sectionNameKeypath: nil, inContext: try session.assignmentsManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }

    public static func collectionByAssignmentName(session: Session, courseID: String, gradingPeriodID: String?, name: String?) throws -> FetchedCollection<Assignment> {
        var predicate: NSPredicate = Assignment.predicate(courseID)
        
        if let name = name {
            predicate = Assignment.predicate(courseID, name: name)
            if let gradingPeriodID = gradingPeriodID {
                predicate = Assignment.predicate(courseID, gradingPeriodID: gradingPeriodID, name: name)
            }
        }
        
        let frc = Assignment.fetchedResults(predicate, sortDescriptors: ["assignmentGroup.position".ascending, "due".ascending, "name".ascending, "id".ascending], sectionNameKeypath: "assignmentGroupName", inContext: try session.assignmentsManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }
    
    public static func collectionByAssignmentGroup(session: Session, courseID: String, gradingPeriodID: String? = nil) throws -> FetchedCollection<Assignment> {
        let predicate = gradingPeriodID.flatMap { Assignment.predicate(courseID, gradingPeriodID: $0) } ?? Assignment.predicate(courseID)
        let frc = Assignment.fetchedResults(predicate, sortDescriptors: ["assignmentGroup.position".ascending, "due".ascending, "name".ascending, "id".ascending], sectionNameKeypath: "assignmentGroupName", inContext: try session.assignmentsManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }

    public static func refreshSignalProducer(session: Session, courseID: String, gradingPeriodID: String?, invalidatingGradingPeriodIDs: [String], cacheKey: (courseID: String, gradingPeriodID: String?) -> String) throws -> SignalProducer<Void, NSError> {
        let context = try session.assignmentsManagedObjectContext()

        // invalidate refresh cache for all other grading periods
        let invalidate = SignalProducer<String, NSError>(values: invalidatingGradingPeriodIDs).map { invalidGradingPeriodID in
            let key = cacheKey(courseID: courseID, gradingPeriodID: invalidGradingPeriodID)
            session.refreshScope.invalidateCache(key, refresh: false)
            if gradingPeriodID != nil {
                session.refreshScope.invalidateCache(cacheKey(courseID: courseID, gradingPeriodID: nil), refresh: false)
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

    public static func refresher(session: Session, courseID: String, gradingPeriodID: String? = nil, invalidatingGradingPeriodIDs: [String] = []) throws -> Refresher {
        let context = try session.assignmentsManagedObjectContext()
        let sync = try refreshSignalProducer(session, courseID: courseID, gradingPeriodID: gradingPeriodID, invalidatingGradingPeriodIDs: invalidatingGradingPeriodIDs) { courseID, gradingPeriodID in
            return collectionCacheKey(context, courseID: courseID, gradingPeriodID: gradingPeriodID)
        }
        let key = collectionCacheKey(context, courseID: courseID, gradingPeriodID: gradingPeriodID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<Assignment>
}
