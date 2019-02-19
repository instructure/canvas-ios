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
import Core

class GradeCircle: UIView {
    public var progress: Double? {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        drawRing(progress: 1, color: UIColor.named(.borderMedium).cgColor)
        drawRing(progress: progress ?? 0, color: Brand.shared.primary.ensureContrast(against: .named(.backgroundLightest)).cgColor)
    }

    func drawRing(progress: Double, color: CGColor) {
        let halfSize: CGFloat = min(bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth: CGFloat = 3

        // The circle path is done in radians and radians do not start at the
        // top of the circle, they start on the right of the circle. Our progress
        // starts at the top so we subtract pi/2 to shift the circle by 90 degrees
        let start = 0 - (Double.pi / 2)
        let end = (Double.pi * 2 * progress) - (Double.pi / 2)

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: CGFloat(halfSize - (desiredLineWidth/2)),
            startAngle: CGFloat(start),
            endAngle: CGFloat(end),
            clockwise: true
        )

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath

        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = desiredLineWidth

        layer.addSublayer(shapeLayer)
    }
}
