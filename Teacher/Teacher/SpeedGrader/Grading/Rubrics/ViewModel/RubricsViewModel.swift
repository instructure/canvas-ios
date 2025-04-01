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
import SwiftUI

class RubricsViewModel: ObservableObject {
    @Published var assessments: APIRubricAssessmentMap = [:] {
        didSet {
            rubricAssessmentDidChange()
        }
    }
    @Published private(set) var isSaving = false
    @Published var rubricComment: String = ""
    @Published var rubricCommentID: String?
    public let assignment: Assignment
    @Published var submission: Submission

    // MARK: - Inputs
    var controller = WeakViewController()

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
    }

    func assessmentForCriteriaID(_ criteriaID: String) -> APIRubricAssessment? {
        let inMemoryAssessment = assessments[criteriaID]
        let databaseAssessment = submission.rubricAssessments?[criteriaID]?.apiEntity
        return inMemoryAssessment ?? databaseAssessment
    }

    func showLongDescription(rubric: Rubric) {
        let web = CoreWebViewController()
        web.title = rubric.desc
        web.webView.loadHTMLString(rubric.longDesc)
        web.addDoneButton(side: .right)
        router.show(web, from: controller, options: .modal(embedInNav: true))
    }

    func promptCustomGrade(_ criteria: Rubric, rubricAssessmentComment: String?) {
        let format = String(localized: "out_of_g_pts", bundle: .core)
        let message = String.localizedStringWithFormat(format, criteria.points)
        let prompt = UIAlertController(title: String(localized: "Customize Grade", bundle: .teacher), message: message, preferredStyle: .alert)
        prompt.addTextField { field in
            field.placeholder = ""
            field.returnKeyType = .done
            field.addTarget(prompt, action: #selector(UIAlertController.performOKAlertAction), for: .editingDidEndOnExit)
            field.accessibilityLabel = String(localized: "Grade", bundle: .teacher)
        }
        prompt.addAction(AlertAction(String(localized: "OK", bundle: .teacher)) { [weak self] _ in
            let text = prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self?.assessments[criteria.id] = APIRubricAssessment(
                comments: rubricAssessmentComment,
                points: DoubleFieldRow.formatter.number(from: text)?.doubleValue
            )
        })
        prompt.addAction(AlertAction(String(localized: "Cancel", bundle: .teacher), style: .cancel))
        AppEnvironment.shared.router.show(prompt, from: controller, options: .modal())
    }

    func totalRubricScore() -> Double? {
        guard isRubricScoreAvailable() else {
            return nil
        }

        let assessments = submission.rubricAssessments // create map only once
        var points = 0.0
        for criteria in assignment.rubric ?? [] where !criteria.ignoreForScoring {
            points += self.assessments[criteria.id]?.points as? Double ??
                assessments?[criteria.id]?.points as? Double ?? 0
        }
        return points
    }

    // MARK: - Private Methods

    private func isRubricScoreAvailable() -> Bool {
        guard assignment.useRubricForGrading else { return false }
        return assessments.contains { _, assessment in
            assessment.points != nil
        }
    }

    private func rubricAssessmentDidChange() {
        if isSaving {
            assessmentsChangedDuringUpload = true
        } else {
            uploadRubricAssessments()
        }
    }

    private func uploadRubricAssessments() {
        if assessments.isEmpty {
            isSaving = false
            return
        }

        isSaving = true
        let prevAssessments = submission.rubricAssessments // create map only once
        var nextAssessments: APIRubricAssessmentMap = [:]

        for criteria in assignment.rubric ?? [] {
            nextAssessments[criteria.id] = assessments[criteria.id] ?? prevAssessments?[criteria.id].map {
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
