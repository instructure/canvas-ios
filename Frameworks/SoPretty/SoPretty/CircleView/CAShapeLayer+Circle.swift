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

private let pi = CGFloat(M_PI) // just cast it dang it <twitching eye>

public extension CAShapeLayer {
    static func pathForAngle(angle: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        // starting point
        let graphCenterRadius = CGFloat(62)
        let startingPoint = CGPoint(x: graphCenterRadius, y: 0)
        path.moveToPoint(startingPoint)
        
        path.addArcWithCenter(.zero, radius: graphCenterRadius, startAngle: 0, endAngle: angle, clockwise: true)
        
        path.applyTransform(CGAffineTransformMakeRotation(pi/2.0 + (2.0*pi-angle)/2.0))
        return path
    }
    
    static func layerForCircleView(width: CGFloat = 16.0, color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = pathForAngle(1.5 * pi).CGPath
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = color.CGColor
        layer.lineWidth = width
        layer.lineCap = kCALineCapButt
        
        return layer
    }
}