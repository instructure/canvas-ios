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
import Observation

@Observable
final class SubmissionCommentViewModel {
    enum ViewState {
        case loading
        case data
        case error
    }

    // MARK: - Dependencies

    private let courseID: String
    private let assignmentID: String
    private let attempt: Int?
    private let router: Router
    private let interactor: SubmissionCommentInteractor

    // MARK: - Outputs

    var viewState: ViewState = .loading
    var comments: [SubmissionComment] = []

    // MARK: - Private properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        courseID: String,
        assignmentID: String,
        attempt: Int?,
        interactor: SubmissionCommentInteractor,
        router: Router
    ) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.attempt = attempt
        self.router = router
        self.interactor = interactor

        getComments()
    }

    // MARK: - Inputs

    func goBack(from viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func postComment(text: String) {
        viewState = .loading

        weak var weakSelf = self

        interactor.postComment(
            courseID: courseID,
            assignmentID: assignmentID,
            attempt: attempt,
            text: text
        )
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    weakSelf?.getComments()
                case .failure:
                    weakSelf?.viewState = .error
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }

    // MARK: - Private functions

    private func getComments() {
        weak var weakSelf = self

        interactor.getComments(
            courseID: courseID,
            assignmentID: assignmentID,
            attempt: attempt
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    weakSelf?.viewState = .error
                }
            },
            receiveValue: { comments in
                weakSelf?.viewState = .data
                weakSelf?.comments = comments
            }
        )
        .store(in: &subscriptions)
    }
}
