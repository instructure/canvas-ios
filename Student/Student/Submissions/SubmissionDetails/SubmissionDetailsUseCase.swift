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

class SubmissionDetailsUseCase: PresenterUseCase {
    init(context: Context, assignmentID: String, userID: String, env: AppEnvironment = .shared) {
        super.init()
        addOperations([
            GetCustomColors(env: env),
            GetContext(context: context, env: env),
            GetAssignment(courseID: context.id, assignmentID: assignmentID),
            GetSubmission(context: context, assignmentID: assignmentID, userID: userID, env: env),
        ])
    }
}
