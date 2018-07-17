//
// Copyright (C) 2018-present Instructure, Inc.
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

extension UIView {
    public func pinToAllSides(ofView: UIView?) {
        guard let view = ofView else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    public func pinToAllSidesOfSuperview() {
        pinToAllSides(ofView: superview)
    }
    
    public func centerInSuperview(xMultiplier: CGFloat = 1, yMultiplier: CGFloat = 1) {
        var yConstant:CGFloat = 0
        var xConstant:CGFloat = 0
        if(xMultiplier != 1) { xConstant = 1 }
        if(yMultiplier != 1) { yConstant = 1 }
        let y = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerY, multiplier: yMultiplier, constant: yConstant)
        let x = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerX, multiplier: xMultiplier, constant: xConstant)
        superview?.addConstraints([x,y])
    }
}
