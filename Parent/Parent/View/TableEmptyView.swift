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

import Foundation
import CanvasCore

class TableEmptyView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var subtextLabel: UILabel!

    @objc var subtext: String? {
        get {
            return subtextLabel.text
        }
        set {
            subtextLabel.isHidden = false
            subtextLabel.text = newValue
        }
    }

    @objc static func nibView() -> TableEmptyView {
        guard let view = Bundle(for: TableEmptyView.self).loadNibNamed("TableEmptyView", owner: self, options: nil)!.first as? TableEmptyView else {
            fatalError("View loaded from NIB is not a TableEmptyView")
        }

        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
    }
}
