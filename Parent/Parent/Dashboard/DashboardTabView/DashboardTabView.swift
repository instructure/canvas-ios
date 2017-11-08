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
    
    

import UIKit

class DashboardTabView: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    fileprivate let selectedAlpha: CGFloat = 1.0
    fileprivate let unselectedAlpha: CGFloat = 0.6
    
    var normalImage: UIImage?
    var selectedImage: UIImage?
    var title: String? {
        didSet {
            guard let title = title else {
                titleLabel.attributedText = NSMutableAttributedString(string: "")
                return
            }

            accessibilityLabel = title

            let attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(3), range: NSRange(location: 0, length: attributedString.length))

            titleLabel.attributedText = attributedString
        }
    }

    let badgeView: BadgeView = BadgeView()

    func color () -> UIColor {
        if UIAccessibilityIsReduceTransparencyEnabled() {
            return .black
        } else {
            return .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
        iconImageView.tintColor = self.color()
        titleLabel.textColor = self.color()

        iconImageView.addSubview(badgeView)
    }
    
    func setSelected(_ selected: Bool) {
        titleLabel.alpha = selected ? selectedAlpha : unselectedAlpha

        iconImageView.alpha = selected ? selectedAlpha : unselectedAlpha
        iconImageView.image = selected ? selectedImage : normalImage
        if selected {
            accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitHeader | UIAccessibilityTraitSelected
        } else {
            accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitHeader
        }
    }
}
