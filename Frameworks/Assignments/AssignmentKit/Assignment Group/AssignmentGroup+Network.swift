//
//  AssignmentGroup+Network.swift
//  Assignments
//
//  Created by Derrick Hathaway on 3/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import ReactiveCocoa
import Marshal

extension AssignmentGroup {
    static func getAssignmentGroups(session: Session, courseID: String, gradingPeriodID: String? = nil) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AssignmentGroupAPI.getAssignmentGroups(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
        return session.paginatedJSONSignalProducer(request).map(insertGradingPeriodID(gradingPeriodID))
    }

    private static func insertGradingPeriodID(gradingPeriodID: String?) -> (assignmentGroups: [JSONObject]) -> [JSONObject] {
        func insertGradingPeriodID(json: JSONObject) -> JSONObject {
            var json = json
            json["grading_period_id"] = gradingPeriodID
            return json
        }
        return { assignmentGroups in assignmentGroups.map(insertGradingPeriodID) }
    }
}
