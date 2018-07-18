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


class VolumeLevelMeterView: UIView {
    override class var layerClass : AnyClass {
        return CAReplicatorLayer.classForCoder()
    }
    
    lazy var tick: CALayer = {
        let tick = CALayer()
        tick.backgroundColor = UIColor.white.cgColor
        tick.frame = CGRect(x: -4, y: 1.5, width: 4, height: self.bounds.size.height - 3.0)
        tick.cornerRadius = 2
        return tick
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let replicator = layer as! CAReplicatorLayer
        replicator.masksToBounds = true
        replicator.instanceTransform = CATransform3DMakeTranslation(6, 0, 0)
        replicator.instanceCount = 0
        replicator.instanceDelay = 0.0
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.0 / UIScreen.main.scale
        layer.cornerRadius = 3
    }
    
    var level: Int = 0 {
        didSet {
            let replicator = layer as! CAReplicatorLayer
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)

            replicator.instanceCount = level + 1
            tick.removeFromSuperlayer()
            replicator.addSublayer(tick)
            
            CATransaction.commit()
        }
    }
}
