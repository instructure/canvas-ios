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
import Foundation

protocol SubmissionCommentsInteractor: AnyObject {
    func getComments() -> AnyPublisher<[SubmissionComment], Error>
    func getIsAssignmentEnhancementsEnabled() -> AnyPublisher<Bool, Error>
}

final class SubmissionCommentsInteractorLive: SubmissionCommentsInteractor {

    // MARK: - Private properties

    private let submissionCommentsStore: ReactiveStore<GetSubmissionComments>
    private let featureFlagsStore: ReactiveStore<GetEnabledFeatureFlags>

    // MARK: - Init

    init(
        courseID: String,
        assignmentID: String,
        userID: String
    ) {
        submissionCommentsStore = ReactiveStore(
            useCase: GetSubmissionComments(
                context: .course(courseID),
                assignmentID: assignmentID,
                userID: userID
            )
        )

        featureFlagsStore = ReactiveStore(
            useCase: GetEnabledFeatureFlags(context: .course(courseID))
        )
    }

    func getComments() -> AnyPublisher<[SubmissionComment], Error> {
        submissionCommentsStore
            .getEntities(keepObservingDatabaseChanges: true)
            .eraseToAnyPublisher()
    }

    func getIsAssignmentEnhancementsEnabled() -> AnyPublisher<Bool, Error> {
        featureFlagsStore
            .getEntities(keepObservingDatabaseChanges: true)
            .map { $0.isFeatureFlagEnabled(.assignmentEnhancements) }
            .eraseToAnyPublisher()
    }
}
