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

import Combine
import Core

protocol SpeedGraderInteractor {
    var state: CurrentValueSubject<SpeedGraderInteractorState, Never> { get }
    var data: SpeedGraderData? { get }

    var assignmentID: String { get }
    var userID: String { get }
    var context: Context { get }

    func loadInitialData()
    func refreshSubmission(forUserId: String)
}

struct SpeedGraderData {
    let assignment: Assignment

    /// Latest submission for each student
    let submissions: [Submission]

    /// Index for the selected student
    let focusedSubmissionIndex: Int
}

enum SpeedGraderInteractorState {
    case loading
    case data
    case error(SpeedGraderInteractorError)
}

enum SpeedGraderInteractorError: Error {
    case userIdNotFound
    case submissionNotFound
    case unexpectedError(Error)
}

let SpeedGraderAllUsersUserID = "speedgrader"
