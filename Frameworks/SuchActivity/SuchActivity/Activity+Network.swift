//
//  Activity+Network.swift
//  SuchActivity
//
//  Created by Derrick Hathaway on 11/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import Marshal
import ReactiveSwift
import TooLegit


extension Activity {
    static func getActivity(session: Session, context: ContextID) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET(context.apiPath/"activity_stream")
        return session.paginatedJSONSignalProducer(request)
    }
}
