//
//  DiscussionEntry+Network.swift
//  Discussions
//
//  Created by Derrick Hathaway on 8/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

import TooLegit
import ReactiveCocoa
import Marshal

extension DiscussionEntry {
    static func getEntries(session: Session, contextID: ContextID, topicID: String, repliesTo entryID: String? = nil) -> SignalProducer<[JSONObject], NSError> {
        
        let path = contextID.apiPath/"discussion_topics"/topicID/"entries"
        
        return attemptProducer { try session.GET(path) }
            .flatMap(.Latest) { session.paginatedJSONSignalProducer($0) }
    }
}
