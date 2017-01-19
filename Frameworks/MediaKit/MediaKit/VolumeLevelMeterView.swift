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
