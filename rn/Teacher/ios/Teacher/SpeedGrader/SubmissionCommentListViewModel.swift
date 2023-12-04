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
import Core
import Foundation
import SwiftUI

class SubmissionCommentListViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading, data([SubmissionComment]), error, empty

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
    private var comments: [SubmissionComment] = []

    // MARK: - Private variables

    private(set) var isAssignmentEnhancementsFeatureFlagEnabled = false
    private var subscriptions = Set<AnyCancellable>()

    init(
        attempt: Int?,
        courseID: String,
        assignmentID: String,
        userID: String
    ) {
        unowned let unownedSelf = self

        Publishers.CombineLatest(
            ReactiveStore(
                useCase: GetSubmissionComments(
                    context: .course(courseID),
                    assignmentID: assignmentID,
                    userID: userID
                )
            ).getEntities(),
            ReactiveStore(
                useCase: GetEnabledFeatureFlags(context: .course(courseID))
            ).getEntities()
        )
        .eraseToAnyPublisher()
        .map { comments, featureFlags in
            unownedSelf.comments = comments
            unownedSelf.isAssignmentEnhancementsFeatureFlagEnabled = featureFlags.isFeatureFlagEnabled(.assignmentEnhancements)
            return unownedSelf.filterComments(comments: comments, attempt: attempt)
        }
        .map { $0.isEmpty ? ViewState.empty : ViewState.data($0) }
        .replaceError(with: .error)
        .assign(to: &$state)

        NotificationCenter.default.publisher(for: .SpeedGraderAttemptPickerChanged)
            .compactMap { $0.object as? Int }
            .sink(receiveValue: { unownedSelf.updateComments(attempt: $0) })
            .store(in: &subscriptions)
    }

    private func filterComments(comments: [SubmissionComment], attempt: Int?) -> [SubmissionComment] {
//        if isAssignmentEnhancementsFeatureFlagEnabled {
//            return comments.filter {
//                $0.attemptFromAPI == nil || $0.attemptFromAPI?.intValue == attempt
//            }
//        } else {
            return comments
//        }
    }

    private func updateComments(attempt: Int?) {
        guard state.isData else { return }
        state = .data(filterComments(comments: comments, attempt: attempt))
    }
}
