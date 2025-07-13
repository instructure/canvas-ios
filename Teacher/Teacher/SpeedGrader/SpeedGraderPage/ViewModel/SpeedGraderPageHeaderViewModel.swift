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
import SwiftUI
import Combine

class SpeedGraderPageHeaderViewModel: ObservableObject {
    @Published private(set) var submissionStatus: SubmissionStatus
    let userNameModel: UserNameModel
    let routeToSubmitter: String?

    private var subscriptions = Set<AnyCancellable>()

    init(
        assignment: Assignment,
        submission: Submission
    ) {
        userNameModel = .init(submission: submission, assignment: assignment)
        let isGroupSubmission = !assignment.gradedIndividually && submission.groupID != nil
        routeToSubmitter = isGroupSubmission ? nil : "/courses/\(assignment.courseID)/users/\(submission.userID)"
        submissionStatus = submission.statusIncludingGradedState
        observeSubmissionStatusInDatabase(submission)
    }

    private func observeSubmissionStatusInDatabase(_ submission: Submission) {
        let filter = NSPredicate(key: (\Submission.id).string, equals: submission.id)
            .and(NSPredicate(key: #keyPath(Submission.attempt), equals: submission.attempt))
        let useCase = LocalUseCase<Submission>(scope: .init(predicate: filter, order: []))
        ReactiveStore(useCase: useCase)
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .catch { _ in Publishers.typedJust([]) }
            .compactMap { $0.first }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedSubmission in
                self?.submissionStatus = updatedSubmission.statusIncludingGradedState
            }
            .store(in: &subscriptions)
    }
}
