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
import UIKit

class RubricCustomRatingViewModel: ObservableObject, Identifiable {
    enum State {
        case value(String)
        case addCustomRating

        var isSelected: Bool {
            switch self {
            case .value: return true
            case .addCustomRating: return false
            }
        }
    }

    // MARK: - Inputs

    var controller = WeakViewController()

    // MARK: - Outputs

    @Published var state: State = .addCustomRating

    // MARK: - Private Properties

    private var assessment: APIRubricAssessment? {
        interactor.assessments.value[rubric.id]
    }
    private let rubric: Rubric
    private let interactor: RubricGradingInteractor

    init(
        rubric: Rubric,
        interactor: RubricGradingInteractor
    ) {
        self.rubric = rubric
        self.interactor = interactor

        interactor.assessments
            .map { assessments -> State in
                let assessmentForRubric = assessments[rubric.id]
                if let customScore = assessmentForRubric?.points, assessmentForRubric?.rating_id.isNilOrEmpty == true {
                    return .value("\(customScore.formatted())")
                } else {
                    return .addCustomRating
                }
            }
            .assign(to: &$state)
    }

    // MARK: - User Actions

    func didTapAddCustomScoreButton() {
        let format = String(localized: "out_of_g_pts", bundle: .core)
        let message = String.localizedStringWithFormat(format, rubric.points)
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
            let points = DoubleFieldRow.formatter.number(from: text)?.doubleValue
            var assessments = interactor.assessments.value
            assessments[rubric.id] = APIRubricAssessment(
                comments: assessment?.comments,
                points: points
            )
            interactor.assessments.send(assessments)
        })
        prompt.addAction(AlertAction(String(localized: "Cancel", bundle: .teacher), style: .cancel))
        router.show(prompt, from: controller, options: .modal())
    }

    func didTapClearCustomScoreButton() {
        var assessments = interactor.assessments.value
        assessments[rubric.id] = APIRubricAssessment(comments: assessment?.comments)
        interactor.assessments.send(assessments)
    }
}
