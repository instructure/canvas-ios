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
                let contextID = ContextID(id: me.courseID, context: .course)
                try Tab.invalidateCache(session: session, contextID: contextID)
                try Page.invalidateCache(session: session, contextID: contextID)
                try Assignment.invalidateCache(session, courseID: me.courseID)
            }
        }
        return remote.flatMap(.concat, transform: local)
    }
}
