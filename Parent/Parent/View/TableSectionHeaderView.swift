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

class TableSectionHeaderView: UIView {
    fileprivate let label = UILabel()

    fileprivate var horizontalConstraints: [NSLayoutConstraint] = []
    fileprivate var verticalConstraints: [NSLayoutConstraint] = []

    var text = "" {
        didSet {
            label.text = text
            accessibilityLabel = text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func setup() {
        backgroundColor = UIColor(r: 232, g: 232, b: 232)

        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        label.font = UIFont.systemFont(ofSize: 13.0)
        updateViewConstraints()

        isAccessibilityElement = true
    }

    func updateViewConstraints() {
        removeConstraints(horizontalConstraints)
        removeConstraints(verticalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[subview]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": label])
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[subview]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": label])

        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }
}
