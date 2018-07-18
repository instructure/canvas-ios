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
