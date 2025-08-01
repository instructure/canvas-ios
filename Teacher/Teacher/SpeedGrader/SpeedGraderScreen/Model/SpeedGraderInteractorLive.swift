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
import CombineSchedulers
import Core
import Foundation

class SpeedGraderInteractorLive: SpeedGraderInteractor {
    let state = CurrentValueSubject<SpeedGraderInteractorState, Never>(.loading)
    let contextInfo = CurrentValueSubject<SpeedGraderContextInfo?, Never>(nil)
    private(set) var data: SpeedGraderData?

    public let assignmentID: String
    public let userID: String
    public let context: Context

    let gradeStatusInteractor: GradeStatusInteractor
    let submissionWordCountInteractor: SubmissionWordCountInteractor
    let customGradebookColumnsInteractor: CustomGradebookColumnsInteractor

    private let env: AppEnvironment
    private let filter: [GetSubmissions.Filter]
    private var subscriptions = Set<AnyCancellable>()
    private let mainScheduler: AnySchedulerOf<DispatchQueue>

    init(
        context: Context,
        assignmentID: String,
        userID: String,
        filter: [GetSubmissions.Filter],
        gradeStatusInteractor: GradeStatusInteractor,
        submissionWordCountInteractor: SubmissionWordCountInteractor,
        customGradebookColumnsInteractor: CustomGradebookColumnsInteractor,
        env: AppEnvironment,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        self.filter = filter
        self.gradeStatusInteractor = gradeStatusInteractor
        self.submissionWordCountInteractor = submissionWordCountInteractor
        self.customGradebookColumnsInteractor = customGradebookColumnsInteractor
        self.env = env
        self.mainScheduler = mainScheduler
    }

    func load() {
        let assignmentLoad = loadAssignment().share()

        Publishers.CombineLatest3(
            assignmentLoad,
            loadCourse(),
            customGradebookColumnsInteractor.loadCustomColumnsData()
        )
        .map { assignment, course, _ in
            SpeedGraderContextInfo(
                courseName: course.name ?? "",
                courseColor: course.color.asColor,
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
                return Publishers.CombineLatest3(
                    loadEnrollments(),
                    loadSubmissions(anonymizeStudents: assignment.anonymizeStudents),
                    gradeStatusInteractor.fetchGradeStatuses()
                )
                .map { (assignment, $0.1) }
                .eraseToAnyPublisher()
            }
            .receive(on: mainScheduler)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state.send(.error(.unexpectedError(error)))
                }
            } receiveValue: { [weak self] (assignment: Assignment, fetchedSubmissions: [Submission]) in
                guard let self else { return }

                let submissions = fetchedSubmissions
                    .sorted(using: .submissionsSortComparator)

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
    func refreshSubmission(forUserId: String) -> AnyPublisher<Void, Error> {
        let submissionUseCase = GetSubmission(context: context, assignmentID: assignmentID, userID: forUserId)
        return ReactiveStore(useCase: submissionUseCase, environment: env)
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
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
            .getEntities(ignoreCache: true, loadAllPages: true)
            .eraseToAnyPublisher()
    }

    private func loadEnrollments() -> AnyPublisher<[Enrollment], Error> {
        let enrollmentsUseCase = GetEnrollments(context: context)
        return ReactiveStore(useCase: enrollmentsUseCase, environment: env)
            .getEntities(loadAllPages: true)
            .eraseToAnyPublisher()
    }
}
