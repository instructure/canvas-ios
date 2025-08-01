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
import CoreData

/// Protocol for managing grade state and grade saving operations in SpeedGrader.
/// Provides reactive grade state updates based on Core Data changes and rubric interactions,
/// and handles API calls on grade modifications.
protocol GradeInteractor {
    var gradeState: AnyPublisher<GradeState, Never> { get }
    func saveGrade(excused: Bool?, grade: String?) -> AnyPublisher<Void, Error>
}

class GradeInteractorLive: GradeInteractor {

    // MARK: - Public Properties

    let gradeState: AnyPublisher<GradeState, Never>

    // MARK: - Private Properties

    private let gradeStateSubject = CurrentValueSubject<GradeState, Never>(GradeState.empty)
    private var cancellables = Set<AnyCancellable>()
    private let assignment: Assignment
    private let submission: Submission
    private let rubricGradingInteractor: RubricGradingInteractor
    private let gradeStateInteractor: GradeStateInteractor
    private let env: AppEnvironment

    // MARK: - Initialization

    init(
        assignment: Assignment,
        submission: Submission,
        rubricGradingInteractor: RubricGradingInteractor,
        gradeStateInteractor: GradeStateInteractor = GradeStateInteractorLive(),
        env: AppEnvironment
    ) {
        self.assignment = assignment
        self.submission = submission
        self.rubricGradingInteractor = rubricGradingInteractor
        self.gradeStateInteractor = gradeStateInteractor
        self.env = env
        self.gradeState = gradeStateSubject
            .dropFirst() // to skip initial empty value
            .eraseToAnyPublisher()

        observeChanges(of: submission.objectID)
    }

    // MARK: - Public Methods

    func saveGrade(excused: Bool? = nil, grade: String? = nil) -> AnyPublisher<Void, Error> {
        GradeSubmission(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            excused: excused,
            grade: grade
        )
        .fetchWithFuture(environment: env)
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func observeChanges(of submissionObjectID: NSManagedObjectID) {
        let submissionPublisher = {
            let predicate = NSPredicate(format: "SELF == %@", submissionObjectID)
            let scope = Scope(predicate: predicate, order: [])
            let useCase = LocalUseCase<Submission>(scope: scope)
            return ReactiveStore(useCase: useCase, environment: env)
                .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
                .catch { _ in Just([]) }
                .compactMap { $0.first }
        }()

        Publishers.CombineLatest3(
            submissionPublisher,
            rubricGradingInteractor.isRubricScoreAvailable,
            rubricGradingInteractor.totalRubricScore
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] updatedSubmission, isRubricScoreAvailable, totalRubricScore in
                guard let self else { return }
                let newState = gradeStateInteractor.gradeState(
                    submission: updatedSubmission,
                    assignment: assignment,
                    isRubricScoreAvailable: isRubricScoreAvailable,
                    totalRubricScore: totalRubricScore
                )
                gradeStateSubject.send(newState)
            }
        )
        .store(in: &cancellables)
    }
}
