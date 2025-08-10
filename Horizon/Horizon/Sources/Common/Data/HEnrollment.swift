//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core

struct HEnrollment {
    let id: String
    let userID: String
    let type: String // e.g "student"
    let computedFinalScore: Double?
    let computedFinalGrade: String?

    init(id: String, userID: String, type: String, computedFinalScore: Double?, computedFinalGrade: String?) {
        self.id = id
        self.userID = userID
        self.type = type
        self.computedFinalScore = computedFinalScore
        self.computedFinalGrade = computedFinalGrade
    }

    init(from entity: Enrollment) {
        self.id = entity.id ?? "" // Should always have a value
        self.userID = entity.userID ?? "" // Should always have a value
        self.type = entity.type
        self.computedFinalScore = entity.computedFinalScore
        self.computedFinalGrade = entity.computedFinalGrade
    }
}
