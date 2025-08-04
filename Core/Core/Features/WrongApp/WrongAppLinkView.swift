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

import UIKit

@IBDesignable
class WrongAppLinkView: UIButton {
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var logoView: UIImageView?
    @IBOutlet weak var wordmark: UIImageView!

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

        switch appName {
        case "parent":
            logoView?.image = UIImage(resource: .parentLogo)
            wordmark.image = UIImage(resource: .parentWordmark)
        case "teacher":
            logoView?.image = UIImage(resource: .teacherLogo)
            wordmark?.image = UIImage(resource: .teacherWordmark)
        default:
            logoView?.image = UIImage(resource: .studentLogo)
            wordmark.image = UIImage(resource: .studentWordmark)
        }
    }
}
