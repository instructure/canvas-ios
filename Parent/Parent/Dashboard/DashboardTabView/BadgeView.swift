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

class BadgeView: UIView {
    fileprivate let minimumSize: CGFloat = 20.0
    fileprivate let padding: CGFloat = 5.0

    var badgeValue: Int = 0 {
        didSet {
            if badgeValue <= 0 {
                self.isHidden = true
            } else {
                self.isHidden = false
            }

            let string = formatter.string(from: NSNumber(value: badgeValue as Int))
            valueLabel.text = string

            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    fileprivate let valueLabel: UILabel = UILabel()
    fileprivate let formatter = NumberFormatter()

    init() {
        super.init(frame: CGRect.zero)

        formatter.usesGroupingSeparator = true

        clipsToBounds = true
        isHidden = true
        backgroundColor = UIColor.parentRedColor()

        valueLabel.textAlignment = .center
        valueLabel.backgroundColor = UIColor.clear
        valueLabel.textColor = UIColor.white
        valueLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        addSubview(valueLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        valueLabel.sizeToFit()

        let badgeLabelWidth = valueLabel.frame.width
        let badgeLabelHeight = valueLabel.frame.height

        let height = max(minimumSize, badgeLabelHeight + padding)
        let width = max(height, badgeLabelWidth + (2 * padding))

        frame = CGRect(x: (superview?.frame ?? CGRect.zero).width - (width / 2.0), y: -(height / 2.0), width: width, height: height)
        layer.cornerRadius = height / 2.0

        valueLabel.frame = CGRect(x: (width / 2.0) - (badgeLabelWidth / 2.0), y: (height / 2.0) - (badgeLabelHeight / 2.0), width: badgeLabelWidth, height: badgeLabelHeight)
    }
}
