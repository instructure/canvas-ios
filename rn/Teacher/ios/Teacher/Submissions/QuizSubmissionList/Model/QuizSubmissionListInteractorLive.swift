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
    private var subscriptions = Set<AnyCancellable>()
    private let usersStore: Store<GetContextUsers>
    private let submissionsStore: Store<GetAllQuizSubmissions>

    public init(env: AppEnvironment,
                courseID: String,
                quizID: String) {
        let usersUseCase = GetContextUsers(
            context: .course(courseID),
            type: .student
        )

        self.usersStore = env.subscribe(usersUseCase)
        let submissionsUseCase = GetAllQuizSubmissions(courseID: courseID, quizID: quizID)
        self.submissionsStore = env.subscribe(submissionsUseCase)

        StoreState
            .combineLatest(usersStore.statePublisher, submissionsStore.statePublisher)
            .subscribe(state)
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(usersStore.allObjects, submissionsStore.allObjects)
            .map { [weak self] in
                self?.getQuizSubmissions(users: $0.0, submissions: $0.1) ?? []
            }
            .subscribe(submissions)
            .store(in: &subscriptions)

        submissionsStore.exhaust()
        usersStore.exhaust(force: true)
    }

    public func setScope(_ scope: QuizSubmissionListScope) -> Future<Void, Never> {
        Future<Void, Never> { [submissionsStore] promise in
            submissionsStore.refresh()
            promise(.success(()))
        }
    }

    // MARK: - Inputs
    public func refresh() -> Future<Void, Never> {
        submissionsStore.refreshWithFuture(force: true)
    }

    // MARK: - Private Helpers
    private func getQuizSubmissions(users: [User], submissions: [QuizSubmission]) -> [QuizSubmissionListItem] {
        let quizsubmissionListItems = users.map { user in
            var status = "Not submitted"
            //TODO: grade in apiCall
            var grade: String?
            if let submission = submissions.first {$0.userID == user.id} {
                status = submission.workflowState == .complete ? "Submitted" : "NOT"
            }

            return QuizSubmissionListItem(
                id: user.id,
                name: user.name,
                status: status,
                grade: grade,
                avatarURL: user.avatarURL
            )
        }

        return quizsubmissionListItems
    }
}
