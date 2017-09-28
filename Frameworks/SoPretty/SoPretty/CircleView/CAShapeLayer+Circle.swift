//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
