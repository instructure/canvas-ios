//
//  ModuleItem+Edits.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 10/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent
import TooLegit
import ReactiveCocoa
import SoLazy
import Marshal
import AssignmentKit
import EnrollmentKit
import SoProgressive

extension ModuleItem {
    public func markDone(session: Session) throws -> SignalProducer<Void, NSError> {
        let context = try session.soEdventurousManagedObjectContext()

        let remote = try ModuleItem.markDone(session, courseID: courseID, moduleID: moduleID, moduleItemID: id)
        let local = attemptProducer {
            try context.save()
            postProgress(session, kind: .MarkedDone)
        }
        let producer = remote.concat(local)

        return producer.on(
            started: { [weak self] in self?.completed = true },
            failed: { [weak self] _ in self?.completed = false },
            interrupted: { [weak self] in self?.completed = false }
        )
    }
    
    public func markRead(session: Session) throws -> SignalProducer<Void, NSError> {
        let context = try session.soEdventurousManagedObjectContext()

        let remote = try ModuleItem.markRead(session, courseID: courseID, moduleID: moduleID, moduleItemID: id)
        let local = attemptProducer {
            try context.save()
            postProgress(session, kind: .Viewed)
        }
        let producer = remote.concat(local)

        return producer.on(
            started: { [weak self] in self?.completed = true },
            failed: { [weak self] _ in self?.completed = false },
            interrupted: { [weak self] in self?.completed = false }
        )
    }

    public func selectMasteryPath(session: Session, assignmentSetID: String) throws -> SignalProducer<Void, NSError> {
        let context = try session.soEdventurousManagedObjectContext()
        // we know this module item has mastery paths if we have an object matching the below predicate
        guard let masteryPathsItem: MasteryPathsItem = try context.findOne(withPredicate: MasteryPathsItem.predicateForMasteryPathsItem(inModule: moduleID, fromItemWithMasteryPaths: id)) else {
            throw NSError(subdomain: "SoEdventurous", code: 1001, title: NSLocalizedString("No Mastery Paths", comment: "Title for alert when a module item doesn't have mastery paths configured"), description: NSLocalizedString("This module item does not have mastery paths configured.", comment: "Body for alert when a module item doesn't have mastery paths configured"))
        }
        
        let remote = try ModuleItem.selectMasteryPath(session, courseID: courseID, moduleID: moduleID, moduleItemID: id, assignmentSetID: assignmentSetID)
        return remote.on(
            next: { [weak self] json in
                guard let me = self else { return }
                do {
                    let newItems: [JSONObject] = try json <| "items"
                    let models: [ModuleItem] = try newItems.map { (var json) in
                        json["course_id"] = me.courseID
                        let item = ModuleItem(inContext: context)
                        try item.updateValues(json, inContext: context)
                        return item
                    }

                    masteryPathsItem.delete(inContext: context)

                    try context.saveFRD()

                    // More assignments have been conditionally released, so let's invalidate the assignments cache
                    try Assignment.invalidateCache(session, courseID: me.courseID)
                } catch {
                    print("Error reading new items from json when selecting mastery path: \(error)")
                }
            }
        ).flatMap(.Concat, transform: { _ in SignalProducer<(), NSError>.empty })
    }
}
