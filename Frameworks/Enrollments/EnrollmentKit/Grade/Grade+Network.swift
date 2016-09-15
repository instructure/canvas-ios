//
//  Grade+Network.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/16/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import ReactiveCocoa
import TooLegit
import Marshal

extension Grade {
    static func getGrades(session: Session, courseID: String, gradingPeriodID: String?) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try GradeAPI.getGrades(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
        return session.paginatedJSONSignalProducer(request).map(insertGradingPeriodID(gradingPeriodID))
    }

    private static func insertGradingPeriodID(gradingPeriodID: String?) -> (grades: [JSONObject]) -> [JSONObject] {
        func insertGradingPeriodID(json: JSONObject) -> JSONObject {
            var json = json
            json["grading_period_id"] = gradingPeriodID
            return json
        }
        return { grades in grades.map(insertGradingPeriodID) }
    }
}
