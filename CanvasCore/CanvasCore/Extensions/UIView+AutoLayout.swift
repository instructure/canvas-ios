//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

extension UIView {
    @objc public func pinToAllSides(ofView: UIView?) {
        guard let view = ofView else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    @objc public func pinToAllSidesOfSuperview() {
        pinToAllSides(ofView: superview)
    }
    
    @objc public func centerInSuperview(xMultiplier: CGFloat = 1, yMultiplier: CGFloat = 1) {
        var yConstant:CGFloat = 0
        var xConstant:CGFloat = 0
        if(xMultiplier != 1) { xConstant = 1 }
        if(yMultiplier != 1) { yConstant = 1 }
        let y = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: yMultiplier, constant: yConstant)
        let x = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: xMultiplier, constant: xConstant)
        superview?.addConstraints([x,y])
    }
}
