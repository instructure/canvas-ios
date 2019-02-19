//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
