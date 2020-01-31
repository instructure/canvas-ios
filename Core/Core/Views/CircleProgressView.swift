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

@IBDesignable
public class CircleProgressView: UIView {
    let track = CAShapeLayer()
    let fill = CAShapeLayer()
    let thickness: CGFloat = 3

    @IBInspectable
    public var progress: Double = 0 {
        didSet {
            fill.strokeEnd = CGFloat(progress)
            setNeedsDisplay()
        }
    }

    public override var bounds: CGRect {
        didSet {
            track.path = ring()
            fill.path = ring()
            setNeedsDisplay()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        track.lineWidth = thickness
        track.path = ring()
        track.fillColor = UIColor.clear.cgColor
        track.strokeColor = UIColor.named(.borderMedium).cgColor
        layer.addSublayer(track)

        fill.fillColor = UIColor.clear.cgColor
        fill.lineWidth = thickness
        fill.path = ring()
        fill.strokeColor = Brand.shared.primary.ensureContrast(against: .named(.backgroundLightest)).cgColor
        fill.strokeEnd = CGFloat(progress)
        layer.addSublayer(fill)
    }

    func ring() -> CGPath {
        let pi = CGFloat(Double.pi)
        return UIBezierPath(
            arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2),
            radius: (min(bounds.width, bounds.height) - thickness) / 2,
            startAngle: -pi * 0.5,
            endAngle: (pi * 1.5),
            clockwise: true
        ).cgPath
    }
}
