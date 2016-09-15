//
//  VolumeLevelMeterView.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 9/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation


class VolumeLevelMeterView: UIView {
    override class func layerClass() -> AnyClass {
        return CAReplicatorLayer.classForCoder()
    }
    
    lazy var tick: CALayer = {
        let tick = CALayer()
        tick.backgroundColor = UIColor.whiteColor().CGColor
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
        
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
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