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
import UIKit

protocol SpeedGraderInteractor: AnyObject {
    var state: CurrentValueSubject<SpeedGraderInteractorState, Never> { get }
    var data: SpeedGraderData? { get }
    /// Submissions can take some time to load so we separate the loading of metadata to have the nav bar themed quickly
    var contextInfo: CurrentValueSubject<SpeedGraderContextInfo?, Never> { get }

    var assignmentID: String { get }
    var userID: String { get }
    var context: Context { get }

    /// Loads all data and updates `state`, `data` and `contextInfo` properties.
    func load()
    func refreshSubmission(forUserId: String)
}

struct SpeedGraderContextInfo: Equatable {
    let courseName: String
    let courseColor: UIColor
    let assignmentName: String
}

struct SpeedGraderData {
    let assignment: Assignment
    let submissions: [Submission]
    let focusedSubmissionIndex: Int
}

enum SpeedGraderInteractorState: Equatable {
    case loading
    case data
    case error(SpeedGraderInteractorError)
}

enum SpeedGraderInteractorError: Error, Equatable {
    case userIdNotFound
    case submissionNotFound
    case unexpectedError(Error)

    static func == (lhs: SpeedGraderInteractorError, rhs: SpeedGraderInteractorError) -> Bool {
        switch (lhs, rhs) {
        case (.userIdNotFound, .userIdNotFound),
             (.submissionNotFound, .submissionNotFound),
             (.unexpectedError, .unexpectedError):
            return true
        default:
            return false
        }
    }
}

let SpeedGraderAllUsersUserId = "speedgrader"
