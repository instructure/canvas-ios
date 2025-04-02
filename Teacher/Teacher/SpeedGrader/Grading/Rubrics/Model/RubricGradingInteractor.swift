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

class RubricGradingInteractor {
    let isSaving = CurrentValueSubject<Bool, Never>(false)
    let assessments = CurrentValueSubject<APIRubricAssessmentMap, Never>([:])
    let showSaveError = PassthroughSubject<Error, Never>()
    let totalRubricScore = CurrentValueSubject<Double, Never>(0)
    let isRubricScoreAvailable = CurrentValueSubject<Bool, Never>(false)

    private var assessmentsChangedDuringUpload = false
    private var subscriptions = Set<AnyCancellable>()
    private let assignment: Assignment
    private let submission: Submission

    init(
        assignment: Assignment,
        submission: Submission
    ) {
        self.assignment = assignment
        self.submission = submission

        uploadGradesOnAssessmentChange()
        calculateRubricScoreOnAssessmentChange()
        calculateRubricScoreAvailabilityOnAssessmentChange(useRubricForGrading: assignment.useRubricForGrading)

        let loadedAssessments = (submission.rubricAssessments ?? [:]).mapValues { $0.apiEntity }
        assessments.send(loadedAssessments)
    }

    // MARK: - Private Methods

    private func calculateRubricScoreOnAssessmentChange() {
        assessments
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

    private func calculateRubricScoreAvailabilityOnAssessmentChange(useRubricForGrading: Bool) {
        assessments
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

    private func uploadGradesOnAssessmentChange() {
        assessments
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
        if assessments.value.isEmpty {
            isSaving.send(false)
            return
        }

        isSaving.send(true)

        GradeSubmission(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            rubricAssessment: assessments.value
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
