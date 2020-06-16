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


import ReactiveSwift

import Marshal

extension ModuleItem {
    private func updateCompleted(session: Session, remote: SignalProducer<(), NSError>, progress: Progress.Kind) throws -> SignalProducer<Void, NSError> {
        let context = try session.soEdventurousManagedObjectContext()
        let scheduler = ManagedObjectContextScheduler(context: context)

        let update = remote
            .on(
                starting: { [weak self] in self?.completed = true },
                failed: { [weak self] _ in self?.completed = false },
                interrupted: { [weak self] in self?.completed = false }
            )
            .observe(on: scheduler)

        let local = attemptProducer {
            try context.save()
            postProgress(session, kind: progress)
        }
        .observe(on: scheduler)

        return update.concat(local)
    }

    public func markDone(session: Session) throws -> SignalProducer<Void, NSError> {
        let remote = try ModuleItem.markDone(session, courseID: courseID, moduleID: moduleID, moduleItemID: id)
        return try updateCompleted(session: session, remote: remote, progress: .markedDone)
    }

    public func markRead(session: Session) throws -> SignalProducer<Void, NSError> {
        let remote = try ModuleItem.markRead(session, courseID: courseID, moduleID: moduleID, moduleItemID: id)
        return try updateCompleted(session: session, remote: remote, progress: .viewed)
    }

    public func markContributed(session: Session) throws -> SignalProducer<Void, NSError> {
        // Empty remote because replying to discussion was the api request
        let remote = SignalProducer<Void, NSError>(value: ())
        return try updateCompleted(session: session, remote: remote, progress: .contributed)
    }

    public func selectMasteryPath(session: Session, assignmentSetID: String) throws -> SignalProducer<Void, NSError> {
        let context = try session.soEdventurousManagedObjectContext()
        // we know this module item has mastery paths if we have an object matching the below predicate
        guard let masteryPathsItem: MasteryPathsItem = try context.findOne(withPredicate: MasteryPathsItem.predicateForMasteryPathsItem(inModule: moduleID, fromItemWithMasteryPaths: id)) else {
            throw NSError(subdomain: "SoEdventurous", code: 1001, title: NSLocalizedString("No Mastery Paths", comment: "Title for alert when a module item doesn't have mastery paths configured"), description: NSLocalizedString("This module item does not have mastery paths configured.", comment: "Body for alert when a module item doesn't have mastery paths configured"))
        }

        let remote = try ModuleItem.selectMasteryPath(session, courseID: courseID, moduleID: moduleID, moduleItemID: id, assignmentSetID: assignmentSetID)
        let local: (JSONObject) -> SignalProducer<Void, NSError> = { [weak self] json in
            return attemptProducer {
                guard let me = self else { return }
                let newItems: [JSONObject] = try json <| "items"
                let _: [ModuleItem] = try newItems.map { itemsJSON in
                    var json = itemsJSON
                    json["course_id"] = me.courseID
                    let item = ModuleItem(inContext: context)
                    try item.updateValues(json, inContext: context)
                    return item
                }

                masteryPathsItem.delete(inContext: context)

                try context.saveFRD()

                // invalidate all the caches that we can to show freed items
                let contextID = Context(.course, id: me.courseID)
                try Tab.invalidateCache(session: session, contextID: contextID)
            }
        }
        return remote.flatMap(.concat, local)
    }
}
