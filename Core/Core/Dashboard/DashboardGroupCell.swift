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

class DashboardGroupCell: UICollectionViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var leftColorView: UIView!
    @IBOutlet weak var termLabel: UILabel!

    func update(_ group: Group?) {
        cardView.accessibilityIdentifier = "DashboardGroupCell.\(group?.id ?? "")"
        cardView.accessibilityLabel = group?.name
        accessibilityElements = [ cardView as Any ]
        let color = group?.color.ensureContrast(against: .named(.white))
        groupNameLabel.text = group?.name
        // courseNameLabel.text = group?.course?.name
        courseNameLabel.textColor = color
        // termLabel?.text = group?.course?.term?.name
        leftColorView?.backgroundColor = color
    }
}
