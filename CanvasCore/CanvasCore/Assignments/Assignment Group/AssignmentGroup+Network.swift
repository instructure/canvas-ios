//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import ReactiveSwift
import Marshal

extension AssignmentGroup {
    static func getAssignmentGroups(_ session: Session, courseID: String, gradingPeriodID: String? = nil) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AssignmentGroupAPI.getAssignmentGroups(session, courseID: courseID, gradingPeriodID: gradingPeriodID)
        return session.paginatedJSONSignalProducer(request).map(insertGradingPeriodID(gradingPeriodID))
    }

    fileprivate static func insertGradingPeriodID(_ gradingPeriodID: String?) -> (_ assignmentGroups: [JSONObject]) -> [JSONObject] {
        func insertGradingPeriodID(_ json: JSONObject) -> JSONObject {
            var json = json
            json["grading_period_id"] = gradingPeriodID
            return json
        }
        return { assignmentGroups in assignmentGroups.map(insertGradingPeriodID) }
    }
}
