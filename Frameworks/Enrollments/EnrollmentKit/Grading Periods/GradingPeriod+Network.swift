//
//  GradingPeriod+Network.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import ReactiveCocoa
import TooLegit
import Marshal

extension GradingPeriod {
    static func getGradingPeriods(session: Session, courseID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try GradingPeriodAPI.getGradingPeriods(session, courseID: courseID)
        return session.paginatedJSONSignalProducer(request, keypath: "grading_periods")
    }
}
