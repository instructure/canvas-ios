//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation

public struct GradeListData: Identifiable, Equatable {
    public let id: String
    let userID: String
    let courseName: String?
    let assignmentSections: [AssignmentSections]
    let isGradingPeriodHidden: Bool
    let gradingPeriods: [GradingPeriod]
    let currentGradingPeriod: GradingPeriod?
    let totalGradeText: String?

    struct AssignmentSections: Identifiable, Equatable {
        let id: String
        let title: String?
        var assignments: [Assignment]
    }
}
