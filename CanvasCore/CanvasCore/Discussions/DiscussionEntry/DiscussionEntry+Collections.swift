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

import UIKit

import CoreData


import ReactiveSwift
import Result
import Marshal


extension DiscussionEntry {
    
    static func extractParticipantsAndEntries(_ jsonView: JSONObject) -> Result<([JSONObject], [JSONObject]), NSError> {
        return Result((try jsonView <| "participants", try jsonView <| "view"))
    }
    
    static func upsertParticipants(_ session: Session, participants: [JSONObject]) -> SignalProducer<(), NSError> {
        return SignalProducer.empty
    }
    
    static func upsertEntries(_ session: Session, contextID: ContextID, topicID: String, entries: [JSONObject], parentID: String? = nil) -> SignalProducer<(), NSError> {
        let predicate = parentID.map { NSPredicate(format: "%K == %@", "parentID", $0) }
        
        let context = Result<NSManagedObjectContext, NSError>(try session.discussionsManagedObjectContext())
        return SignalProducer(result: context)
            .flatMap(.latest) { (context: NSManagedObjectContext)->SignalProducer<[DiscussionEntry], NSError> in
                syncSignalProducer(predicate, inContext: context, fetchRemote: SignalProducer(value: entries), postProcess: { entry, json in
                    entry.contextID = contextID
                    entry.topicID = topicID
                    try entry.syncAllReplies(json, contextID: contextID, topicID: topicID, inContext: context)
                })
            }
            .flatMap(.merge) { (_: [DiscussionEntry]) -> SignalProducer<(), NSError> in SignalProducer.empty }
    }
    
    static func refreshEntriesAndParticipants(_ session: Session, contextID: ContextID, topicID: String) -> SignalProducer<(), NSError> {
        return DiscussionTopic.getDiscussionTopicView(session, contextID: contextID, topicID: topicID)
            .attemptMap(extractParticipantsAndEntries)
            .flatMap(.merge) { (participants, entries) in
                return upsertParticipants(session, participants: participants)
                    .concat(upsertEntries(session, contextID: contextID, topicID: topicID, entries: entries))
            }
    }
    
    public static func refresher(_ session: Session, contextID: ContextID, topicID: String) throws -> Refresher {
        let sync = refreshEntriesAndParticipants(session, contextID: contextID, topicID: topicID)
        
        let context = try session.discussionsManagedObjectContext()
        let key = cacheKey(context, [contextID.description, topicID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func predicate(_ contextID: ContextID, topicID: String, parentEntryID: String?) -> NSPredicate {
        if let parentID = parentEntryID {
            return NSPredicate(format: "%K == %@ && %K == %@ && %K == %@", "rawContextID", contextID.canvasContextID, "topicID", topicID, "parentID", parentID)
        } else {
            return NSPredicate(format: "%K == %@ && %K == %@ && %K == nil", "rawContextID", contextID.canvasContextID, "topicID", topicID, "parentID")
        }
    }
    
    public static func collection(_ session: Session, contextID: ContextID, topicID: String, parentEntryID: String? = nil) throws -> FetchedCollection<DiscussionEntry> {
        
        let context = try session.discussionsManagedObjectContext()
        let pred = predicate(contextID, topicID: topicID, parentEntryID: parentEntryID)
        let descriptors = ["date".descending]
        
        return try FetchedCollection(frc: context.fetchedResults(pred, sortDescriptors: descriptors))
    }
}
