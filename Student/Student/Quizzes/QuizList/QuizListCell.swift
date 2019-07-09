//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import Core

class QuizListCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: DynamicLabel?
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var pointsDot: DynamicLabel?
    @IBOutlet weak var pointsLabel: DynamicLabel?
    @IBOutlet weak var questionsLabel: DynamicLabel?
    @IBOutlet weak var statusDot: DynamicLabel?
    @IBOutlet weak var statusLabel: DynamicLabel?
    @IBOutlet weak var titleLabel: DynamicLabel?

    func update(quiz: Quiz?, color: UIColor?) {
        dateLabel?.text = quiz?.dueText
        titleLabel?.text = quiz?.title
        iconImageView?.image = .icon(.quiz, .line)
        iconImageView?.tintColor = color
        if let pointsText = quiz?.pointsPossibleText {
            pointsLabel?.text = pointsText
            pointsLabel?.isHidden = false
            pointsDot?.isHidden = false
        } else {
            pointsLabel?.isHidden = true
            pointsDot?.isHidden = true
        }
        questionsLabel?.text = quiz?.nQuestionsText
        if let statusText = quiz?.lockStatusText {
            statusLabel?.text = statusText
            statusLabel?.isHidden = false
            statusDot?.isHidden = false
        } else {
            statusLabel?.isHidden = true
            statusDot?.isHidden = true
        }
    }
}
