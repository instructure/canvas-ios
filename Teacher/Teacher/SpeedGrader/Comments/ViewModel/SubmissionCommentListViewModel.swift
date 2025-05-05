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
        case data
        case error
        case empty
    }

    // MARK: - Outputs

    @Published private(set) var state: ViewState = .loading
    @Published private(set) var cellViewModels: [SubmissionCommentListCellViewModel] = []

    // MARK: - Private variables

    private let assignment: Assignment
    private let latestSubmission: Submission
    private let currentUserId: String?

    private var submissions: [Submission] = []
    private var allComments: [SubmissionComment] = []
    private var selectedAttemptNumber: Int?
    private var isAssignmentEnhancementsEnabled = false

    private let interactor: SubmissionCommentsInteractor
    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    private var attemptNumberForNewComment: Int? {
        isAssignmentEnhancementsEnabled ? selectedAttemptNumber : nil
    }

    // MARK: - Init

    init(
        assignment: Assignment,
        latestSubmission: Submission,
        latestAttemptNumber: Int?,
        currentUserId: String?,
        interactor: SubmissionCommentsInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        env: AppEnvironment
    ) {
        self.assignment = assignment
        self.latestSubmission = latestSubmission
        self.submissions = []

        self.selectedAttemptNumber = latestAttemptNumber
        self.currentUserId = currentUserId

        self.interactor = interactor
        self.env = env

        unowned let unownedSelf = self

        Publishers.CombineLatest3(
            interactor.getSubmissionAttempts(),
            interactor.getComments(),
            interactor.getIsAssignmentEnhancementsEnabled()
        )
        .map { submissions, comments, isAssignmentEnhancementsEnabled in
            unownedSelf.submissions = submissions
            unownedSelf.allComments = comments
            unownedSelf.isAssignmentEnhancementsEnabled = isAssignmentEnhancementsEnabled
            return unownedSelf
                .filterComments(comments, for: unownedSelf.selectedAttemptNumber)
                .map(unownedSelf.commentViewModel)
        }
        .receive(on: scheduler)
        .sinkFailureOrValue(
            receiveFailure: { _ in
                unownedSelf.state = .error
                unownedSelf.cellViewModels = []
            },
            receiveValue: {
                unownedSelf.state = $0.isEmpty ? .empty : .data
                unownedSelf.cellViewModels = $0
            }
        )
        .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: .SpeedGraderAttemptPickerChanged)
            .compactMap { $0.object as? Int }
            .sink { unownedSelf.updateComments(attempt: $0) }
            .store(in: &subscriptions)
    }

    // MARK: - Get comments

    private func updateComments(attempt: Int?) {
        selectedAttemptNumber = attempt
        guard state == .data || state == .empty else { return }

        let comments = filterComments(allComments, for: attempt)
        state = comments.isEmpty ? .empty : .data
        cellViewModels = comments.map(commentViewModel)
    }

    private func filterComments(_ comments: [SubmissionComment], for attempt: Int?) -> [SubmissionComment] {
        if isAssignmentEnhancementsEnabled {
            return comments.filter {
                $0.attemptFromAPI == nil || $0.attemptFromAPI?.intValue == attempt
            }
        } else {
            return comments
        }
    }

    private func commentViewModel(comment: SubmissionComment) -> SubmissionCommentListCellViewModel {
        .init(
            comment: comment,
            assignment: assignment,
            submission: submissionForComment(comment),
            currentUserId: currentUserId,
            router: env.router
        )
    }

    private func submissionForComment(_ comment: SubmissionComment) -> Submission {
        let result = submissions.first(where: { $0.attempt == comment.attempt }) ?? latestSubmission
        if result.assignment == nil {
            result.assignment = assignment
        }
        return result
    }

    // MARK: - Send comment

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
