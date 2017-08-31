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
    
    fileprivate var horizontalConstraints: [NSLayoutConstraint] = []
    fileprivate var verticalConstraints: [NSLayoutConstraint] = []

    fileprivate let label = UILabel()

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

        layer.cornerRadius = frame.height/2
    }

    func setup() {
        clipsToBounds = true

        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        updateViewConstraints()
    }

    func updateViewConstraints() {
        removeConstraints(horizontalConstraints)
        removeConstraints(verticalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftMargin-[subview]-rightMargin-|", options: NSLayoutFormatOptions(), metrics: ["leftMargin": insets.left, "rightMargin": insets.right], views: ["subview": label])
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-topMargin-[subview]-bottomMargin-|", options: NSLayoutFormatOptions(), metrics: ["topMargin": insets.top, "bottomMargin": insets.bottom], views: ["subview": label])

        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }

}
