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

public class QuizSubmissionListInteractorLive: QuizSubmissionListInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var submissions = CurrentValueSubject<[QuizSubmissionListItem], Never>([])

    // MARK: - Private
    private let submissionsStore: Store<GetAllQuizSubmissions>
    private var subscriptions = Set<AnyCancellable>()

    public init(env: AppEnvironment,
                courseID: String,
                quizID: String) {
        let useCase = GetAllQuizSubmissions(courseID: courseID, quizID: quizID)
        self.submissionsStore = env.subscribe(useCase)

        submissionsStore
            .statePublisher
            .subscribe(state)
            .store(in: &subscriptions)

        submissionsStore
            .allObjects
            .map { $0.map { submission in
                QuizSubmissionListItem(submission)
            } }
            .subscribe(submissions)
            .store(in: &subscriptions)

        submissionsStore.refresh()
    }

    // MARK: - Inputs
    public func refresh() -> Future<Void, Never> {
        submissionsStore.refreshWithFuture(force: true)
    }
}
