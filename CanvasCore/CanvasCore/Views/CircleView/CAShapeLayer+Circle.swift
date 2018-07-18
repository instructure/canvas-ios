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

private let pi = CGFloat.pi

public extension CAShapeLayer {
    static func pathForAngle(_ angle: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()

        // starting point
        let graphCenterRadius = CGFloat(62)
        let startingPoint = CGPoint(x: graphCenterRadius, y: 0)
        path.move(to: startingPoint)

        path.addArc(withCenter: .zero, radius: graphCenterRadius, startAngle: 0, endAngle: angle, clockwise: true)

        path.apply(CGAffineTransform(rotationAngle: pi/2.0 + (2.0*pi-angle)/2.0))
        return path
    }

    static func layerForCircleView(_ width: CGFloat = 16.0, color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = pathForAngle(1.5 * pi).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = width
        layer.lineCap = kCALineCapButt

        return layer
    }
}
