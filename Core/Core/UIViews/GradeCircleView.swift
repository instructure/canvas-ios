//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import UIKit

public class GradeCircleReusableView: UICollectionReusableView {
    public let gradeCircleView: GradeCircleView?

    static let topPadding: CGFloat = 12

    public override init(frame: CGRect) {
        gradeCircleView = GradeCircleView(frame: CGRect.zero)
        super.init(frame: frame)
        guard let gradeCircleView = gradeCircleView else { return }
        addSubview(gradeCircleView)
        gradeCircleView.pin(inside: self)

        let border = UIView(frame: CGRect.zero)
        border.backgroundColor = UIColor.borderMedium
        addSubview(border)
        let margin: CGFloat = 16
        border.pin(inside: self, leading: margin, trailing: margin, top: nil, bottom: 0)
        border.addConstraintsWithVFL("V:[view(1)]")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("No implemented")
    }
}

public class GradeCircleView: UIView {
    @IBOutlet weak var circlePoints: UILabel!
    @IBOutlet weak var circleLabel: UILabel!
    /** Displays the checkmark in the middle of the progress circle. */
    @IBOutlet weak var circleComplete: UIImageView!
    @IBOutlet weak var gradeCircle: CircleProgressView!
    @IBOutlet weak var displayGrade: UILabel!
    @IBOutlet weak var outOfLabel: UILabel!
    @IBOutlet weak var latePenaltyLabel: UILabel!
    @IBOutlet weak var finalGradeLabel: UILabel!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    /**
     - parameters:
       - circleColor: The color of the grade circle. If not specified it will use the default color specified in `CircleProgressView`.
     */
    public func update(_ assignment: Assignment, circleColor: UIColor? = nil) {
        gradeCircle.progress = 1 // make sure it's never spinning

        if let circleColor = circleColor {
            gradeCircle.color = circleColor
        }

        circleComplete.isAccessibilityElement = true
        // in this case the submission should always be there because canvas generates
        // submissions for every user for every assignment but just in case
        guard let submission = assignment.submission, submission.workflowState != .unsubmitted else {
            isHidden = true
            return
        }

        guard submission.grade != nil || submission.excused == true else {
            isHidden = true
            return
        }

        isHidden = false

        let isPassFail = assignment.gradingType == .pass_fail
        circlePoints.isHidden = isPassFail
        circleLabel.isHidden = isPassFail
        let isFail = isPassFail && submission.grade == "incomplete"
        circleComplete.image = isFail ? .xLine : .checkSolid
        circleComplete.tintColor = isFail ? .borderLight : circleColor
        circleComplete.isHidden = !isPassFail

        // Update grade circle
        if let score = submission.score {
            circlePoints.text = NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)

            if let pointsPossible = assignment.pointsPossible {
                gradeCircle.progress = CGFloat(score / pointsPossible)
                gradeCircle.accessibilityLabel = assignment.scoreOutOfPointsPossibleText
            } else {
                gradeCircle.accessibilityLabel = "\(score) \(assignment.pointsText ?? "")"
            }
        }

        circleLabel.text = assignment.pointsText

        // Update the display grade
        displayGrade.isHidden = assignment.gradingType == .points || submission.late == true
        let gradeText = GradeFormatter.string(from: assignment, style: .short) ?? ""
        displayGrade.attributedText = NSAttributedString(string: gradeText, attributes: [NSAttributedString.Key.accessibilitySpeechPunctuation: true])

        // Update the outOf label
        outOfLabel.text = assignment.outOfText

        // Update the Late penalty and Final Grade
        latePenaltyLabel.isHidden = true
        finalGradeLabel.isHidden = true
        if assignment.hasLatePenalty {
            latePenaltyLabel.isHidden = false
            finalGradeLabel.isHidden = false

            latePenaltyLabel.text = assignment.latePenaltyText
            finalGradeLabel.text = assignment.finalGradeText
        }

        // Update for excused
        if submission.excused == true {
            circlePoints.isHidden = true
            circleLabel.isHidden = true
            circleComplete.isHidden = false
            gradeCircle?.progress = 1
            displayGrade.isHidden = false
            displayGrade.text = NSLocalizedString("Excused", bundle: .core, comment: "")
        }

        // Update for hidden quantitative data
        if assignment.hideQuantitativeData {
            outOfLabel.isHidden = true
            displayGrade.isHidden = gradeText.isEmpty || gradeText == "-"
            latePenaltyLabel.isHidden = true
            finalGradeLabel.isHidden = true
            circleComplete.isHidden = false
            circlePoints.isHidden = true
            circleLabel.isHidden = true
            gradeCircle?.progress = 1
            gradeCircle.accessibilityLabel = gradeCircle.accessibilityLabel?.containsNumber == true ? nil : gradeCircle.accessibilityLabel
        }
    }
}
