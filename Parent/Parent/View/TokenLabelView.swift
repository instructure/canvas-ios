
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

class TokenLabelView: UIView {
    
    private var horizontalConstraints: [NSLayoutConstraint] = []
    private var verticalConstraints: [NSLayoutConstraint] = []

    private let label = UILabel()

    var text = ""  {
        didSet {
            guard !text.isEmpty else {
                removeConstraints(horizontalConstraints)
                removeConstraints(verticalConstraints)

                horizontalConstraints = []
                verticalConstraints = []
                sizeToFit()
                return
            }

            label.text = text
            updateViewConstraints()
            sizeToFit()
        }
    }

    var insets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10) {
        didSet {
            updateViewConstraints()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = CGRectGetHeight(frame)/2
    }

    func setup() {
        clipsToBounds = true

        label.font = UIFont.systemFontOfSize(13.0)
        label.textColor = UIColor.whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        updateViewConstraints()
    }

    func updateViewConstraints() {
        removeConstraints(horizontalConstraints)
        removeConstraints(verticalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leftMargin-[subview]-rightMargin-|", options: .DirectionLeadingToTrailing, metrics: ["leftMargin": insets.left, "rightMargin": insets.right], views: ["subview": label])
        verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-topMargin-[subview]-bottomMargin-|", options: .DirectionLeadingToTrailing, metrics: ["topMargin": insets.top, "bottomMargin": insets.bottom], views: ["subview": label])

        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }

}