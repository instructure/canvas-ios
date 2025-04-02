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

import Core
import Combine
import SwiftUI

class RubricsViewModel: ObservableObject {
    let assessments = CurrentValueSubject<APIRubricAssessmentMap, Never>([:])
    @Published private(set) var isSaving = false
    @Published var rubricComment: String = ""
    @Published var rubricCommentID: String?
    let assignment: Assignment
    @Published var submission: Submission
    private(set) var criteriaViewModels: [RubricCriteriaViewModel] = []

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Inputs
    var controller = WeakViewController() {
        didSet {
            criteriaViewModels.forEach { $0.controller = controller }
        }
    }

    // MARK: - Private
    private var assessmentsChangedDuringUpload = false
    private let router: Router

    // MARK: - Public Methods

    init(
        assignment: Assignment,
        submission: Submission,
        router: Router = AppEnvironment.shared.router
    ) {
        self.assignment = assignment
        self.submission = submission
        self.router = router
        criteriaViewModels = (assignment.rubric ?? []).map { [unowned self] criteria in
            let rubricCommentBinding = Binding(
                get: { self.rubricComment },
                set: { self.rubricComment = $0 }
            )
            let rubricCommentIdBinding = Binding(
                get: { self.rubricCommentID },
                set: { self.rubricCommentID = $0 }
            )
            return RubricCriteriaViewModel(
                criteria: criteria,
                isFreeFormCommentsEnabled: assignment.freeFormCriterionCommentsOnRubric,
                assessments: assessments,
                rubricComment: rubricCommentBinding,
                rubricCommentID: rubricCommentIdBinding
            )
        }

        assessments
            .dropFirst()
            .sink { [weak self] _ in
                self?.rubricAssessmentDidChange()
            }
            .store(in: &subscriptions)

        let loadedAssessments = (submission.rubricAssessments ?? [:]).mapValues { $0.apiEntity }
        assessments.send(loadedAssessments)
    }

    func assessmentForCriteriaID(_ criteriaID: String) -> APIRubricAssessment? {
        let inMemoryAssessment = assessments.value[criteriaID]
        let databaseAssessment = submission.rubricAssessments?[criteriaID]?.apiEntity
        return inMemoryAssessment ?? databaseAssessment
    }

    func totalRubricScore() -> Double {
        let assessments = submission.rubricAssessments // create map only once
        var points = 0.0
        for criteria in assignment.rubric ?? [] where !criteria.ignoreForScoring {
            points += self.assessments.value[criteria.id]?.points as? Double ??
                assessments?[criteria.id]?.points as? Double ?? 0
        }
        return points
    }

    func isRubricScoreAvailable() -> Bool {
        guard assignment.useRubricForGrading else { return false }
        return assessments.value.contains { _, assessment in
            assessment.points != nil
        }
    }

    // MARK: - Private Methods

    private func rubricAssessmentDidChange() {
        if isSaving {
            assessmentsChangedDuringUpload = true
        } else {
            uploadRubricAssessments()
        }
    }

    private func uploadRubricAssessments() {
        if assessments.value.isEmpty {
            isSaving = false
            return
        }

        isSaving = true
        let prevAssessments = submission.rubricAssessments // create map only once
        var nextAssessments: APIRubricAssessmentMap = [:]

        for criteria in assignment.rubric ?? [] {
            nextAssessments[criteria.id] = assessments.value[criteria.id] ?? prevAssessments?[criteria.id].map {
                APIRubricAssessment(comments: $0.comments, points: $0.points, rating_id: $0.ratingID)
            }
        }

        GradeSubmission(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: submission.userID,
            rubricAssessment: nextAssessments
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

        isSaving = false

        if let error = error {
            showError(error)
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "OK", bundle: .teacher), style: .default))
        router.show(alert, from: controller, options: .modal())
    }
}
