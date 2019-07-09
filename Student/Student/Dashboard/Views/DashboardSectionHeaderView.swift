//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class DashboardSectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var rightButton: UIButton?
    @IBOutlet weak var titleLabel: UILabel?

    var rightActionCallback: (() -> Void)?

    func configure(title: String, rightText: String?, rightAction: (() -> Void)?) {
        titleLabel?.text = title
        rightButton?.setTitle(rightText, for: .normal)
        rightButton?.tintColor = Brand.shared.primary.ensureContrast(against: .named(.white))
        if let action = rightAction {
            rightActionCallback = action
            rightButton?.isHidden = false
            rightButton?.isEnabled = true
            rightButton?.accessibilityLabel = NSLocalizedString("See All Courses", bundle: .student, comment: "")
        } else {
            rightActionCallback = nil
            rightButton?.isHidden = true
            rightButton?.isEnabled = false
            rightButton?.accessibilityLabel = nil
        }
    }

    @IBAction func rightButtonTapped(_ sender: Any) {
        rightActionCallback?()
    }
}
