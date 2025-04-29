//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import CombineSchedulers
import Core
import Foundation
import SwiftUI

class SubmissionCommentListViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case data([SubmissionComment])
        case error
        case empty

        var isData: Bool {
            if case .data = self {
                return true
            } else {
                return false
            }
        }
    }

    // MARK: - Outputs

    @Published private(set) var state: ViewState = .loading

    // MARK: - Private variables

    let assignment: Assignment
    private let submissions: [Submission]
    private let initialSubmission: Submission
    private let currentUserId: String?

    private let interactor: SubmissionCommentsInteractor
    private let env: AppEnvironment
    private var comments: [SubmissionComment] = []
    private var attempt: Int?
    private var isAssignmentEnhancementsEnabled = false
    private var subscriptions = Set<AnyCancellable>()

    var attemptNumberForNewComment: Int? {
        isAssignmentEnhancementsEnabled ? attempt : nil
    }

    init(
        assignment: Assignment,
        submissions: [Submission],
        initialSubmission: Submission,
        initialAttemptNumber: Int?,
        currentUserId: String?,
        interactor: SubmissionCommentsInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        env: AppEnvironment
    ) {
        self.assignment = assignment
        self.initialSubmission = initialSubmission
        self.submissions = submissions

        self.attempt = initialAttemptNumber
        self.currentUserId = currentUserId

        self.interactor = interactor
        self.env = env

        unowned let unownedSelf = self

        Publishers.CombineLatest(
            interactor.getComments(),
            interactor.getIsAssignmentEnhancementsEnabled()
        )
        .map { comments, isAssignmentEnhancementsEnabled in
            unownedSelf.comments = comments
            unownedSelf.isAssignmentEnhancementsEnabled = isAssignmentEnhancementsEnabled
            return unownedSelf.filterComments(comments: comments, attempt: unownedSelf.attempt)
        }
        .receive(on: scheduler)
        .map { $0.isEmpty ? ViewState.empty : ViewState.data($0) }
        .replaceError(with: .error)
        .assign(to: &$state)

        NotificationCenter.default.publisher(for: .SpeedGraderAttemptPickerChanged)
            .compactMap { $0.object as? Int }
            .sink(receiveValue: { unownedSelf.updateComments(attempt: $0) })
            .store(in: &subscriptions)
    }

    private func filterComments(comments: [SubmissionComment], attempt: Int?) -> [SubmissionComment] {
        if isAssignmentEnhancementsEnabled {
            return comments.filter {
                $0.attemptFromAPI == nil || $0.attemptFromAPI?.intValue == attempt
            }
        } else {
            return comments
        }
    }

    private func updateComments(attempt: Int?) {
        self.attempt = attempt
        guard state.isData else { return }
        state = .data(filterComments(comments: comments, attempt: attempt))
    }

    func cellConfig(with comment: SubmissionComment) -> SubmissionCommentListCellViewModel {
        .init(
            comment: comment,
            assignment: assignment,
            submission: submissionForComment(comment),
            currentUserId: currentUserId,
            router: env.router
        )
    }

    func submissionForComment(_ comment: SubmissionComment) -> Submission {
        let result = submissions.first(where: { $0.attempt == comment.attempt }) ?? initialSubmission
        if result.assignment == nil {
            result.assignment = assignment
        }
        return result
    }

    func sendTextComment(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {
        interactor.createTextComment(text, attemptNumber: attemptNumberForNewComment) { result in
            completion(result.mapSendCommentResult())
        }
    }

    func sendMediaComment(type: MediaCommentType, url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        interactor.createMediaComment(type: type, url: url, attemptNumber: attemptNumberForNewComment) { result in
            completion(result.mapSendCommentResult())
        }
    }

    func sendFileComment(batchId: String, completion: @escaping (Result<String, Error>) -> Void) {
        interactor.createFileComment(batchId: batchId, attemptNumber: attemptNumberForNewComment) { result in
            completion(result.mapSendCommentResult())
        }
    }
}

private extension Result<Void, Error> {
    func mapSendCommentResult() -> Result<String, Error> {
        switch self {
        case .success:
            let successMessage = String(localized: "Comment sent successfully", bundle: .teacher)
            return .success(successMessage)
        case .failure(let error):
            if error.localizedDescription.isEmpty {
                let genericErrorMessage = String(localized: "Could not save the comment.", bundle: .teacher)
                return .failure(NSError.instructureError(genericErrorMessage))
            } else {
                return .failure(error)
            }
        }
    }
}
