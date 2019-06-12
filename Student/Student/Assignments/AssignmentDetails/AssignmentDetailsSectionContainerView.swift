//
// Copyright (C) 2019-present Instructure, Inc.
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

class AssignmentDetailsSectionContainerView: UIView {
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var header: DynamicLabel!
    @IBOutlet weak var subHeader: DynamicLabel!
    @IBOutlet weak var divider: DividerView!
    @IBOutlet var contentView: UIView!

    @IBInspectable var headerText: String? {
        didSet {
            header?.text = headerText
        }
    }

    @IBInspectable var subHeaderText: String? {
        didSet {
            subHeader?.text = subHeaderText
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        contentView = loadFromXib()
        backgroundColor = UIColor.named(.backgroundLightest)
        contentView.backgroundColor = UIColor.named(.backgroundLightest)
    }
}
