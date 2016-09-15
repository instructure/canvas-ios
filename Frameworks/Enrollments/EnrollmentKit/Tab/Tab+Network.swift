//
//  Tab+Network.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/15/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import TooLegit
import ReactiveCocoa
import Marshal


extension Tab {
    public static func get(session: Session, contextID: ContextID) -> SignalProducer<[JSONObject], NSError> {
        let path = contextID.apiPath/"tabs"
        return attemptProducer { try session.GET(path) }
            .flatMap(.Merge) { request in
                return session.paginatedJSONSignalProducer(request)
            }
    }
}