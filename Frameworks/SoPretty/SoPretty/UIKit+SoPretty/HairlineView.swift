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

public enum Orientation {
    case Vertical
    case Horizontal
}

public class HairlineView: UIView {
    
    public var color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2) {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            lineLayer.fillColor = color.CGColor
            CATransaction.commit()
        }
    }
    
    public var orientation: Orientation = .Horizontal {
        didSet {
            setNeedsLayout()
        }
    }
    
    lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = self.color.CGColor
        self.layer.addSublayer(layer)
        return layer
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let bounds = self.bounds
        let lineWidth = 1.0 / UIScreen.mainScreen().scale
        
        let rect: CGRect
        if orientation == .Vertical {
            rect = CGRect(origin: .zero, size: CGSize(width: lineWidth, height: bounds.size.height))
        } else {
            rect = CGRect(x: 0, y: bounds.height - lineWidth, width: bounds.width, height: lineWidth)
        }
        
        lineLayer.path = UIBezierPath(rect: rect).CGPath
        lineLayer.frame = bounds
        
        CATransaction.commit()
    }
}