//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import RealmSwift

public class Submission: Object {
    @objc public dynamic var id: String = ""
    @objc public dynamic var assignmentID: String = ""
    @objc public dynamic var grade: String?
    @objc public dynamic var submittedAt: Date?
    @objc public dynamic var late: Bool = false
    @objc public dynamic var excused: Bool = false
    @objc public dynamic var missing: Bool = false

    @objc private dynamic var rawWorkflowState: String = APISubmission.WorkflowState.unsubmitted.rawValue
    public var workflowState: APISubmission.WorkflowState {
        set {
            rawWorkflowState = newValue.rawValue
        }
        get {
            return APISubmission.WorkflowState(rawValue: rawWorkflowState) ?? .unsubmitted
        }
    }

    @objc private dynamic var rawLatePolicyStatus: String?
    public var latePolicyStatus: APISubmission.LatePolicyStatus? {
        set {
            rawLatePolicyStatus = newValue?.rawValue
        }
        get {
            return rawLatePolicyStatus.flatMap(APISubmission.LatePolicyStatus.init(rawValue:))
        }
    }

    private var rawPointsDeducted = RealmOptional<Double>()
    public var pointsDeducted: Double? {
        set {
            rawPointsDeducted = RealmOptional(newValue)
        }
        get {
            return rawPointsDeducted.value
        }
    }

    private var rawScore = RealmOptional<Double>()
    public var score: Double? {
        set {
            rawScore = RealmOptional(newValue)
        }
        get {
            return rawScore.value
        }
    }

    override public class func primaryKey() -> String? {
        return #keyPath(Submission.id)
    }
}
