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
    public let courseID: String
    public let quizID: String

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let usersStore: Store<GetQuizSubmissionUsers>
    private let submissionsStore: Store<GetAllQuizSubmissions>
    private let quizStore: Store<GetQuiz>
    private let courseStore: Store<GetCourse>

    private var filter = CurrentValueSubject<QuizSubmissionListFilter, Never>(.all)
    private let context: Context

    public init(env: AppEnvironment,
                courseID: String,
                quizID: String) {
        self.context = Context(.course, id: courseID)
        self.usersStore = env.subscribe(GetQuizSubmissionUsers(courseID: courseID))
        self.submissionsStore = env.subscribe(GetAllQuizSubmissions(courseID: courseID, quizID: quizID))
        self.quizStore = env.subscribe(GetQuiz(courseID: courseID, quizID: quizID))
        self.courseStore = env.subscribe(GetCourse(courseID: courseID))

        self.courseID = courseID
        self.quizID = quizID

        Publishers
            .CombineLatest(usersStore.allObjects, submissionsStore.allObjects)
            .map {
                QuizSubmissionListItem.make(users: $0.0, submissions: $0.1)
            }
            .combineLatest(filter) {
                $0.applyFilter(filter: $1)
            }
            .subscribe(submissions)
            .store(in: &subscriptions)

        Publishers
            .CombineLatest4(usersStore.statePublisher, submissionsStore.statePublisher, quizStore.statePublisher, submissions)
            .map {values in
                let storeStates = [values.0, values.1, values.2]
                let submissions = values.3
                if storeStates.contains(.loading) {
                    return .loading
                } else if storeStates.contains(.error) {
                    return .error
                } else if storeStates.contains(.data), !submissions.isEmpty {
                    return .data
                } else {
                    return .empty
                }
            }
            .subscribe(state)
            .store(in: &subscriptions)

        quizStore
            .allObjects
            .map {
                $0.first?.title ?? ""
            }
            .subscribe(quizTitle)
            .store(in: &subscriptions)

        submissionsStore.exhaust()
        usersStore.exhaust()
        quizStore.refresh()
        courseStore.refresh()
    }

    public func createMessageUserInfo() -> Future<[String: Any], Never> {
        let quizTitle = quizTitle.value
        let submissions = submissions.value
        let contextCode = context.canvasContextID
        let courseName = courseStore.first?.name ?? ""
        return Future<[String: Any], Never> {  promise in
            let recipients: [[String: Any?]] = submissions.map {
                [
                    "id": $0.id,
                    "name": $0.displayName,
                    "avatar_url": $0.avatarURL,
                ] as [String: Any?]
            }
            let userInfo = [
                "recipients": recipients,
                "subject": quizTitle,
                "contextName": courseName,
                "contextCode": contextCode,
                "canAddRecipients": false,
                "onlySendIndividualMessages": true,
            ]
            promise(.success(userInfo))
        }
    }

    public func setFilter(_ newFilter: QuizSubmissionListFilter) -> Future<Void, Never> {
        Future<Void, Never> { [filter] promise in
            filter.send(newFilter)
            promise(.success(()))
        }
    }

    // MARK: - Inputs
    public func refresh() -> Future<Void, Never> {
        usersStore.exhaust(force: true)
        quizStore.refresh(force: true)
        return submissionsStore.refreshWithFuture(force: true)
    }
}
