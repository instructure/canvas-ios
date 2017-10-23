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
    case vertical
    case horizontal
}

open class HairlineView: UIView {
    
    open var color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2) {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            lineLayer.fillColor = color.cgColor
            CATransaction.commit()
        }
    }
    
    open var orientation: Orientation = .horizontal {
        didSet {
            setNeedsLayout()
        }
    }
    
    lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = self.color.cgColor
        self.layer.addSublayer(layer)
        return layer
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isOpaque = false
        backgroundColor = UIColor.clear
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let bounds = self.bounds
        let lineWidth = 1.0 / UIScreen.main.scale
        
        let rect: CGRect
        if orientation == .vertical {
            rect = CGRect(origin: .zero, size: CGSize(width: lineWidth, height: bounds.size.height))
        } else {
            rect = CGRect(x: 0, y: bounds.height - lineWidth, width: bounds.width, height: lineWidth)
        }
        
        lineLayer.path = UIBezierPath(rect: rect).cgPath
        lineLayer.frame = bounds
        
        CATransaction.commit()
    }
}
