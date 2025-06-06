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

public extension UITableViewCell {
    @IBInspectable
    var fullDivider: Bool {
        get {
            return separatorInset == .zero
        }
        set {
            if newValue {
                preservesSuperviewLayoutMargins = true
                separatorInset = UIEdgeInsets.zero
                layoutMargins = UIEdgeInsets.zero
            }
        }
    }

    func setCellState(isAvailable: Bool, isUserInteractionEnabled: Bool = false) {
        self.contentView.alpha = isAvailable ? 1 : 0.3
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }

    func setupInstDisclosureIndicator() {
        let image = UIImageView(image: UIImage.arrowOpenRightLine)
        image.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        image.tintColor = .textDark
        accessoryView = image
    }
}
