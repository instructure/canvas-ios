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
import SwiftUI

class SpeedGraderInteractorLive: SpeedGraderInteractor {
    let state = CurrentValueSubject<SpeedGraderInteractorState, Never>(.loading)
    let contextInfo = CurrentValueSubject<SpeedGraderContextInfo?, Never>(nil)
    private(set) var data: SpeedGraderData?

    public let assignmentID: String
    public let userID: String
    public let context: Context

    private let env: AppEnvironment
    private let filter: [GetSubmissions.Filter]
    private var subscriptions = Set<AnyCancellable>()
    private let sortNeedsGradingSubmissionsFirst: Bool

    init(
        context: Context,
        assignmentID: String,
        userID: String,
        filter: [GetSubmissions.Filter],
        sortNeedsGradingSubmissionsFirst: Bool,
        env: AppEnvironment
    ) {
        self.env = env
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        self.filter = filter
        self.sortNeedsGradingSubmissionsFirst = sortNeedsGradingSubmissionsFirst
    }

    func load() {
        let assignmentLoad = loadAssignment().share()

        Publishers.CombineLatest(
            assignmentLoad,
            loadCourse()
        )
        .map { assignment, course in
            SpeedGraderContextInfo(
                courseName: course.name ?? "",
                courseColor: course.color,
                assignmentName: assignment.name
            )
        }
        .ignoreFailure()
        .sink { [weak self] contextInfo in
            self?.contextInfo.send(contextInfo)
        }
        .store(in: &subscriptions)

        assignmentLoad
            .flatMap { [weak self] assignment in
                guard let self else {
                    return Publishers.noInstanceFailure(output: (Assignment, [Submission]).self)
                }
                return Publishers.CombineLatest(
                    loadEnrollments(),
                    loadSubmissions(anonymizeStudents: assignment.anonymizeStudents)
                )
                .map { (assignment, $0.1) }
                .eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state.send(.error(.unexpectedError(error)))
                }
            } receiveValue: { [weak self] (assignment: Assignment, fetchedSubmissions: [Submission]) in
                guard let self else { return }

                let submissions = sortNeedsGradingSubmissionsFirst
                    ? fetchedSubmissions.sorted(by: Self.needsGradingFirstSortingStrategy)
                    : fetchedSubmissions

                if submissions.isEmpty {
                    state.send(.error(.submissionNotFound))
                    return
                }

                let firstIndex = (userID == SpeedGraderAllUsersUserId)
                    ? submissions.firstIndex { _ in true }
                    : submissions.firstIndex { $0.userID == self.userID }

                guard let focusedSubmissionIndex = firstIndex else {
                    state.send(.error(.userIdNotFound))
                    return
                }

                data = SpeedGraderData(
                    assignment: assignment,
                    submissions: submissions,
                    focusedSubmissionIndex: focusedSubmissionIndex
                )
                state.send(.data)
            }
            .store(in: &subscriptions)
    }

    /// This only refreshes the submission in CoreData but won't update the entity published in the interactor's state.
    func refreshSubmission(forUserId: String) {
        let submissionUseCase = GetSubmission(context: context, assignmentID: assignmentID, userID: forUserId)
        ReactiveStore(useCase: submissionUseCase, environment: env)
            .getEntities(ignoreCache: true)
            .sink()
            .store(in: &subscriptions)
    }

    // MARK: - Entity Loaders

    private func loadAssignment() -> AnyPublisher<Assignment, Error> {
        let assignmentUseCase = GetAssignment(
            courseID: context.id,
            assignmentID: assignmentID,
            include: [.overrides]
        )
        return ReactiveStore(useCase: assignmentUseCase, environment: env)
            .getEntities()
            .tryMap { try $0.first.unwrapOrThrow() }
            .eraseToAnyPublisher()
    }

    private func loadCourse() -> AnyPublisher<Course, Error> {
        Publishers.CombineLatest(
            ReactiveStore(useCase: GetCourse(courseID: context.id), environment: env)
                .getEntities()
                .tryMap { try $0.first.unwrapOrThrow() },
            ReactiveStore(useCase: GetCustomColors(), environment: env)
                .getEntities()
        )
        .map { course, _ in course }
        .eraseToAnyPublisher()
    }

    private func loadSubmissions(anonymizeStudents: Bool) -> AnyPublisher<([Submission]), Error> {
        let submissionsUseCase = GetSubmissions(context: context, assignmentID: assignmentID, filter: filter)
        submissionsUseCase.shuffled = anonymizeStudents
        return ReactiveStore(useCase: submissionsUseCase, environment: env)
            .getEntities(loadAllPages: true)
            .eraseToAnyPublisher()
    }

    private func loadEnrollments() -> AnyPublisher<[Enrollment], Error> {
        let enrollmentsUseCase = GetEnrollments(context: context)
        return ReactiveStore(useCase: enrollmentsUseCase, environment: env)
            .getEntities(loadAllPages: true)
            .eraseToAnyPublisher()
    }
}

// MARK: - Grading-Based Sorting Strategy

public enum SpeedGraderUserInfoKey {
    static let sortNeedsGradingSubmissionsFirst = "sortNeedsGradingSubmissionsFirst"
}

private extension SpeedGraderInteractorLive {

    static let needsGradingFirstSortingStrategy: (Submission, Submission) -> Bool = { sub1, sub2 in
        /// Put 'Needs Grading' first
        if sub1.needsGrading != sub2.needsGrading {
            return sub1.needsGrading
        }

        /// Put 'Graded' last
        if sub1.isGraded != sub2.isGraded {
            return sub2.isGraded
        }

        return false
    }
}
