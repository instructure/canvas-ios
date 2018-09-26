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
import Core

struct AssignmentDetailsViewModel {
    let name: String
    let pointsPossible: Double?
    let dueAt: Date
    let submissionTypes: [String]
    var pointsPossibleText: String? {
        guard let points = pointsPossible else { return nil }
        let pointsFormat = NSLocalizedString("plural_pts", bundle: .student, comment: "")
        return String.localizedStringWithFormat(pointsFormat, points)
    }
    var dueText: String {
        return DateFormatter.localizedString(from: dueAt, dateStyle: .medium, timeStyle: .short)
    }
    var submissionTypeText: String {
        return ListFormatter.localizedString(from: submissionTypes, conjunction: .or)
    }
}
