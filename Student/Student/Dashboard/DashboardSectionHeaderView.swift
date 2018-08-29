//
// Copyright (C) 2018-present Instructure, Inc.
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

class DashboardSectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    var rightActionCallback: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }

    func setup() {
        backgroundColor = .clear
        reset()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    func reset() {
        titleLabel.text = ""
        rightButton.isEnabled = false
        rightButton.isHidden = true
        rightActionCallback = nil
        rightButton.accessibilityLabel = nil
    }

    func configure(title: String, rightButtonText: String?, rightAction: (() -> Void)?) {
        titleLabel.text = title
        rightButton.setTitle(rightButtonText, for: .normal)
        if let action = rightAction {
            rightActionCallback = action
            rightButton.isHidden = false
            rightButton.isEnabled = true
            rightButton.accessibilityLabel = "see_all_courses"
        }
    }

    @IBAction func rightButtonTapped(_ sender: Any) {
        rightActionCallback?()
    }
}
