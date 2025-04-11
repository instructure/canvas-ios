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

protocol RubricGradingInteractor {
    var assessments: AnyPublisher<APIRubricAssessmentMap, Never> { get }
    var isSaving: CurrentValueSubject<Bool, Never> { get }
    var showSaveError: PassthroughSubject<Error, Never> { get }
    var totalRubricScore: CurrentValueSubject<Double, Never> { get }
    var isRubricScoreAvailable: CurrentValueSubject<Bool, Never> { get }

    func clearRating(criterionId: String)
    func selectRating(criterionId: String, points: Double, ratingId: String)
    func hasAssessmentUserComment(criterionId: String) -> Bool
    func updateComment(criterionId: String, comment: String?)
}

class RubricGradingInteractorLive: RubricGradingInteractor {

    // MARK: - Public Properties

    let assessments: AnyPublisher<APIRubricAssessmentMap, Never>
    let isSaving = CurrentValueSubject<Bool, Never>(false)
    let showSaveError = PassthroughSubject<Error, Never>()
    let totalRubricScore = CurrentValueSubject<Double, Never>(0)
    let isRubricScoreAvailable = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Private Properties

    private var assessmentsChangedDuringUpload = false
    private var subscriptions = Set<AnyCancellable>()
    private let assignment: Assignment
    private let submission: Submission
    /// Modification is only allowed internally to keep logic inside this class. Read-only values are accessible via the `assessments` property.
    private let assessmentsSubject = CurrentValueSubject<APIRubricAssessmentMap, Never>([:])

    // MARK: - Public Methods

    init(
        assignment: Assignment,
        submission: Submission
    ) {
        self.assignment = assignment
        self.submission = submission
        self.assessments = assessmentsSubject.removeDuplicates().eraseToAnyPublisher()

        uploadGrades(onChangeOf: assessmentsSubject)
        calculateRubricScore(onChangeOf: assessmentsSubject)
        calculateRubricScoreAvailability(onChangeOf: assessmentsSubject, useRubricForGrading: assignment.useRubricForGrading)

        let loadedAssessments = (submission.rubricAssessments ?? [:]).mapValues { $0.apiEntity }
        assessmentsSubject.send(loadedAssessments)
    }

    /// Clears the grade but keeps the comment on the criterion.
    func clearRating(criterionId: String) {
        var assessments = assessmentsSubject.value
        let assessmentForCriterion = assessments[criterionId]
        assessments[criterionId] = APIRubricAssessment(comments: assessmentForCriterion?.comments)
        assessmentsSubject.send(assessments)
    }

    /// Selects the given rating on the criterion while keeping the previously added comment.
    func selectRating(
        criterionId: String,
        points: Double,
        ratingId: String
    ) {
        var assessments = assessmentsSubject.value
        let oldCommentOnCriterion = assessments[criterionId]?.comments
        assessments[criterionId] = APIRubricAssessment(
            comments: oldCommentOnCriterion,
            points: points,
            rating_id: ratingId
        )
        assessmentsSubject.send(assessments)
    }

    func hasAssessmentUserComment(criterionId: String) -> Bool {
        assessmentsSubject.value[criterionId]?.comments?.isNotEmpty == true
    }

    /// Updates the comment but leaves the point and rating id intact on the assessment.
    func updateComment(criterionId: String, comment: String?) {
        var assessments = assessmentsSubject.value
        let oldAssessment = assessments[criterionId]
        assessments[criterionId] = APIRubricAssessment(
            comments: comment,
            points: oldAssessment?.points,
            rating_id: oldAssessment?.rating_id ?? APIRubricAssessment.customRatingId
        )
        assessmentsSubject.send(assessments)
    }

    // MARK: - Private Methods

    private func calculateRubricScore(
        onChangeOf assessmentsSubject: CurrentValueSubject<APIRubricAssessmentMap, Never>
    ) {
        assessmentsSubject
            .map { [assignment] in
                var points = 0.0
                for criteria in assignment.rubric ?? [] where !criteria.ignoreForScoring {
                    points += $0[criteria.id]?.points as? Double ?? 0
                }
                return points
            }
            .sink { [weak totalRubricScore] in
                totalRubricScore?.send($0)
            }
            .store(in: &subscriptions)
    }

    private func calculateRubricScoreAvailability(
        onChangeOf assessmentsSubject: CurrentValueSubject<APIRubricAssessmentMap, Never>,
        useRubricForGrading: Bool
    ) {
        assessmentsSubject
            .map {
                guard useRubricForGrading else { return false }
                return $0.contains { _, assessment in
                    assessment.points != nil
                }
            }
            .sink { [weak isRubricScoreAvailable] in
                isRubricScoreAvailable?.send($0)
            }
            .store(in: &subscriptions)
    }

    private func uploadGrades(onChangeOf assessmentsSubject: CurrentValueSubject<APIRubricAssessmentMap, Never>) {
        assessmentsSubject
            .dropFirst(2) // 1st is the initial value, 2nd is the load from the submission
            .sink { [weak self] _ in
                self?.rubricAssessmentDidChange()
            }
            .store(in: &subscriptions)
    }

    private func rubricAssessmentDidChange() {
        if isSaving.value {
            assessmentsChangedDuringUpload = true
        } else {
            uploadRubricAssessments()
        }
    }

    private func uploadRubricAssessments() {
        if assessmentsSubject.value.isEmpty {
            isSaving.send(false)
            return
        }

        isSaving.send(true)

        GradeSubmission(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            rubricAssessment: assessmentsSubject.value
        ).fetch { [weak self] _, _, error in performUIUpdate {
            self?.handleUploadFinished(error: error)
        } }
    }

    private func handleUploadFinished(error: Error?) {
        if assessmentsChangedDuringUpload {
            assessmentsChangedDuringUpload = false
            uploadRubricAssessments()
            return
        }

        isSaving.send(false)

        if let error {
            showSaveError.send(error)
        }
    }
}
