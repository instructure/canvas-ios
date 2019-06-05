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

import Foundation
import UIKit

@IBDesignable
class WrongAppLinkView: UIView {
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
        logoView?.tintColor = color
        nameLabel?.textColor = color
        nameLabel?.attributedText = NSAttributedString(string: appName.uppercased(), attributes: [.kern: 1.5])
    }
}
