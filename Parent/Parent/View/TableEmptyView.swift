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
    
    

import Foundation
import CanvasCore

class TableEmptyView: UIView {

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var textLabel: UILabel!

    static func nibView() -> TableEmptyView {
        guard let view = Bundle(for: TableEmptyView.self).loadNibNamed("TableEmptyView", owner: self, options: nil)!.first as? TableEmptyView else {
            ❨╯°□°❩╯⌢"View loaded from NIB is not a TableEmptyView"
        }

        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
    }

}
