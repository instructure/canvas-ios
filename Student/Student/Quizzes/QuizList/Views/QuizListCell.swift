//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

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

    func update(quiz: QuizListItemModel?, color: UIColor?) {
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
        questionsLabel?.text = quiz?.questionCountText
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
