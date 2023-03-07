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
    public var quizTitle = CurrentValueSubject<String, Never>("")

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let usersStore: Store<GetQuizSubmissionUsers>
    private let submissionsStore: Store<GetAllQuizSubmissions>
    private let quizStore: Store<GetQuiz>

    public init(env: AppEnvironment,
                courseID: String,
                quizID: String) {
        self.usersStore = env.subscribe(GetQuizSubmissionUsers(courseID: courseID))
        self.submissionsStore = env.subscribe(GetAllQuizSubmissions(courseID: courseID, quizID: quizID))
        self.quizStore = env.subscribe(GetQuiz(courseID: courseID, quizID: quizID))

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

        quizStore
            .allObjects
            .first()
            .map {
                $0.first?.title ?? ""
            }
            .subscribe(quizTitle)
            .store(in: &subscriptions)

        submissionsStore.exhaust()
        usersStore.exhaust(force: true)
        quizStore.refresh()
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
    private func getQuizSubmissions(users: [QuizSubmissionUser], submissions: [QuizSubmission]) -> [QuizSubmissionListItem] {
        users.map { user in
            var status: QuizSubmissionWorkflowState = .untaken
            var score: String?
            if let submission = submissions.first(where: {$0.userID == user.id}) {
                status = submission.workflowState
                if let submissionScore = submission.score {
                    score = String(format: "%g", submissionScore)
                }
            }
            return QuizSubmissionListItem(
                id: user.id,
                displayName: User.displayName(user.name, pronouns: user.pronouns),
                name: user.name,
                status: status,
                score: score,
                avatarURL: user.avatarURL
            )
        }
    }
}
