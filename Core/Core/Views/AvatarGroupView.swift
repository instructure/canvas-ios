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
open class AvatarGroupView: UIView {
    let frontAvatarView = AvatarView()
    let backAvatarView = AvatarView()

    public func loadUsers(_ users: [(name: String, url: URL?)]) {
        frontAvatarView.name = users.first?.name ?? ""
        frontAvatarView.url = users.first?.url
        if users.count < 2 {
            backAvatarView.isHidden = true
        } else {
            backAvatarView.isHidden = false
            backAvatarView.name = users[1].name
            backAvatarView.url = users[1].url
        }
        setNeedsLayout()
    }

    open override func layoutSubviews() {
        if frontAvatarView.superview == nil {
            addSubview(backAvatarView)
            addSubview(frontAvatarView)
        }
        if backAvatarView.isHidden {
            frontAvatarView.frame = bounds
        } else {
            let w = bounds.width
            let r = w / 3 // radius of avatar
            let d = r * 2 // diameter
            backAvatarView.frame = CGRect(x: 0, y: 0, width: d, height: d)
            frontAvatarView.frame = CGRect(x: w - d, y: w - d, width: d, height: d)
            let path = UIBezierPath( // space around back avatar
                arcCenter: CGPoint(x: r, y: r),
                radius: r + 2,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            path.addArc( // subtract space around front avatar
                withCenter: CGPoint(x: w - r, y: w - r),
                radius: r + 2,
                startAngle: CGFloat.pi * 2,
                endAngle: 0,
                clockwise: false
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            backAvatarView.layer.mask = mask
        }
    }
}
