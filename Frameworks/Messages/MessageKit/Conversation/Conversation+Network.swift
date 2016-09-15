//
//  Conversation+Network.swift
//  Messages
//
//  Created by Nathan Armstrong on 6/30/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import ReactiveCocoa
import Marshal

extension Conversation {
    public static func getConversations(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let parameters = ["include": ["participant_avatars"]]
        let request = try session.GET(api/v1/"conversations", parameters: parameters)
        return session.paginatedJSONSignalProducer(request)
    }
}