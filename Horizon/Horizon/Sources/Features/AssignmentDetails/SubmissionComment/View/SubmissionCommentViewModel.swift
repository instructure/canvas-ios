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
import CombineExt
import Observation
import Core

@Observable
final class SubmissionCommentViewModel {
    // MARK: - Outputs

    var comments: [SubmissionComment] = []

    // MARK: - Private properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        context: Context,
        assignmentID: String,
        userID: String,
        attempt: Int?,
        interactor: SubmissionCommentInteractor
    ) {
        interactor.getComments(
            context: context,
            assignmentID: assignmentID,
            attempt: attempt,
            userID: userID
        )
        .replaceError(with: [])
        .assign(to: \.comments, on: self, ownership: .weak)
        .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func goBack() {}
}
