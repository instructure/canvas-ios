//
//  Group+Network.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 2/17/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import SoPretty
import TooLegit
import SoPersistent
import ReactiveCocoa
import Marshal

extension Group {
    static func getAllGroups(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET(api/v1/"users/self/groups")
        return session.paginatedJSONSignalProducer(request)
    }
}