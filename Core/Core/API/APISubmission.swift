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

// https://canvas.instructure.com/doc/api/submissions.html#Submission
struct APISubmission: Codable, Equatable {
    let assignment_id: String
    let grade: String?
    let score: Double?
    let submitted_at: Date?
    let late: Bool
    let excused: Bool
    let missing: Bool
    let workflow_state: WorkflowState

    // late policies
    let late_policy_status: LatePolicyStatus?
    let points_deducted: Double?

    enum LatePolicyStatus: String, Codable {
        case late, missing, none
    }

    enum WorkflowState: String, Codable {
        case submitted, unsubmitted, graded, pending_review
    }
}
