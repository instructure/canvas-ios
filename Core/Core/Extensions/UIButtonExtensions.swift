//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

private var barButtonBadgeKey: UInt8 = 0
public extension UIButton {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &barButtonBadgeKey) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }

    func addBadge(number: UInt, withOffset offset: CGPoint = CGPoint.zero, color: UIColor = UIColor.textInfo) {
        badgeLayer?.removeFromSuperlayer()

        if number == 0 { return }

        let badge = CAShapeLayer()
        let radius: CGFloat = 9.75
        let radiusOffset: CGFloat = 1.2
        let location = CGPoint(x: frame.width - ((radius * radiusOffset) + offset.x), y: ((radius * radiusOffset) + offset.y))

        badge.fillColor = UIColor.white.cgColor
        badge.strokeColor = color.cgColor
        let badgeOrigin = CGPoint(x: location.x - radius, y: location.y - radius)
        let badgeRect = CGRect(origin: badgeOrigin, size: CGSize(width: radius * 2, height: radius * 2))
        badge.path = UIBezierPath(ovalIn: badgeRect).cgPath
        layer.addSublayer(badge)

        let label = CATextLayer()
        label.string = NumberFormatter.localizedString(from: NSNumber(value: number), number: .none)
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 12
        label.font = UIFont.scaledNamedFont(.semibold12)
        let labelRect = CGRect(origin: CGPoint(x: badgeRect.origin.x, y: badgeRect.origin.y + 2.5), size: badgeRect.size)
        label.frame = labelRect
        label.foregroundColor = color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)

        objc_setAssociatedObject(self, &barButtonBadgeKey, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
