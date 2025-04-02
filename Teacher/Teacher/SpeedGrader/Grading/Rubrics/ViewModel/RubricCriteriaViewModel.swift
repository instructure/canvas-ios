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
import SwiftUI

class RubricRatingViewModel: ObservableObject, Identifiable {
    @Published var isSelected: Bool = false {
        didSet {
            if isSelected {
                didSelectRating()
            } else {
                didClearRating()
            }
        }
    }
    let tooltip: String
    let value: String
    let accessibilityLabel: String

    private var assessment: APIRubricAssessment? {
        assessmentsPublisher.value[rubricId]
    }
    private let rating: RubricRating
    private let rubricId: String
    private let assessmentsPublisher: CurrentValueSubject<APIRubricAssessmentMap, Never>
    private var subscriptions = Set<AnyCancellable>()

    init(
        rating: RubricRating,
        rubricId: String,
        assessments: CurrentValueSubject<APIRubricAssessmentMap, Never>
    ) {
        self.rating = rating
        self.rubricId = rubricId
        self.assessmentsPublisher = assessments

        tooltip = rating.desc + (rating.longDesc.isEmpty ? "" : "\n" + rating.longDesc)
        value = "\(rating.points.formatted())"
        accessibilityLabel = rating.desc.isEmpty ? value : rating.desc
        assessments
            .map {
                let assessmentForRubric = $0[rubricId]
                let isThisRatingSelected = assessmentForRubric?.rating_id == rating.id
                return isThisRatingSelected
            }
            .removeDuplicates()
            .assign(to: &$isSelected)
        // custom score, value=
//        if selectedRatingId == rating.id, let customScore = assessment?.points {
//            return "\(customScore.formatted())"
//        }
    }

    private func didSelectRating() {
        var assessments = assessmentsPublisher.value
        assessments[rubricId] = APIRubricAssessment(
            comments: assessment?.comments,
            points: rating.points,
            rating_id: rating.id
        )
        assessmentsPublisher.send(assessments)
    }

    private func didClearRating() {
        var assessments = assessmentsPublisher.value
        assessments[rubricId] = APIRubricAssessment(comments: assessment?.comments)
        assessmentsPublisher.send(assessments)
    }
}

class RubricCriteriaViewModel: ObservableObject, Identifiable {

    // MARK: - Inputs
    var controller = WeakViewController()
    @Binding var rubricComment: String
    @Binding var rubricCommentID: String?

    // MARK: - Outputs

    var shouldShowLongDescriptionButton: Bool {
        criteria.longDesc.isEmpty == false
    }
    var shouldShowRubricNotUsedForScoringMessage: Bool {
        criteria.ignoreForScoring
    }
    var description: String {
        criteria.desc
    }
    var shouldShowRubricRatings: Bool {
        !isFreeFormCommentsEnabled
    }
    var shouldShowAddFreeFormCommentButton: Bool {
        isFreeFormCommentsEnabled && assessment?.comments?.isEmpty != false
    }
    @Published private(set) var customGrade: Double?
    @Published private(set) var selectedRatingId: String?
    var addCommentButtonA11yID: String {
        "SpeedGrader.Rubric.\(criteria.id).addCommentButton"
    }
    var ratingViewModels: [RubricRatingViewModel]

    // MARK: - Private Properties

    private let criteria: Rubric
    private let isFreeFormCommentsEnabled: Bool
    private let router: Router
    private var assessment: APIRubricAssessment? {
        assessmentsPublisher.value[criteria.id]
    }
    private let assessmentsPublisher: CurrentValueSubject<APIRubricAssessmentMap, Never>
    private var subscriptions = Set<AnyCancellable>()

    init(
        criteria: Rubric,
        isFreeFormCommentsEnabled: Bool,
        assessments: CurrentValueSubject<APIRubricAssessmentMap, Never>,
        rubricComment: Binding<String>,
        rubricCommentID: Binding<String?>,
        router: Router = AppEnvironment.shared.router
    ) {
        self.criteria = criteria
        self.isFreeFormCommentsEnabled = isFreeFormCommentsEnabled
        self.assessmentsPublisher = assessments
        self._rubricComment = rubricComment
        self._rubricCommentID = rubricCommentID
        self.router = router
        ratingViewModels = (criteria.ratings ?? [])
            .reversed()
            .map {
                RubricRatingViewModel(
                    rating: $0,
                    rubricId: criteria.id,
                    assessments: assessments
                )
            }

        let criteriaId = criteria.id
        assessmentsPublisher
            .map {
                let assessment = $0[criteriaId]
                if isFreeFormCommentsEnabled || assessment?.rating_id.isNilOrEmpty == true {
                    return assessment?.points
                }
                return nil
            }
            .assign(to: &$customGrade)

        assessmentsPublisher
            .map {
                $0[criteriaId]?.rating_id
            }
            .assign(to: &$selectedRatingId)
    }

    // MARK: - Public Helpers

    // MARK: - User Actions

    func didTapAddCustomScoreButton() {
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
            guard let self else { return }
            let text = prompt.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            var assessments = assessmentsPublisher.value
            assessments[criteria.id] = APIRubricAssessment(
                comments: assessment?.comments,
                points: DoubleFieldRow.formatter.number(from: text)?.doubleValue
            )
            assessmentsPublisher.send(assessments)
        })
        prompt.addAction(AlertAction(String(localized: "Cancel", bundle: .teacher), style: .cancel))
        router.show(prompt, from: controller, options: .modal())
    }

    func didTapClearCustomScoreButton() {
        var assessments = assessmentsPublisher.value
        assessments[criteria.id] = APIRubricAssessment(comments: assessment?.comments)
        assessmentsPublisher.send(assessments)
    }

    func didTapAddCommentButton() {
        rubricComment = ""
        rubricCommentID = criteria.id
    }

    func didTapShowLongDescriptionButton() {
        let web = CoreWebViewController()
        web.title = criteria.desc
        web.webView.loadHTMLString(criteria.longDesc)
        web.addDoneButton(side: .right)
        router.show(web, from: controller, options: .modal(embedInNav: true))
    }

    // MARK: - Private Helpers

}
