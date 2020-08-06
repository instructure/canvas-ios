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

import Foundation
import UIKit

@IBDesignable
class WrongAppLinkView: UIButton {
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var logoView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?

    var color = UIColor.studentLogoColor
    @IBInspectable var appName: String = "student" {
        didSet {
            switch appName {
            case "parent":
                color = UIColor.parentLogoColor
            case "teacher":
                color = UIColor.teacherLogoColor
            default:
                color = UIColor.studentLogoColor
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .backgroundLightest
        contentView?.isUserInteractionEnabled = false
        logoView?.tintColor = color
        nameLabel?.textColor = color
        nameLabel?.attributedText = NSAttributedString(string: appName.uppercased(), attributes: [.kern: 1.5])
    }
}
