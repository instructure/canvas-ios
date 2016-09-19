//
//  RecorButton.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 9/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import AVFoundation


class RecordButton: UIButton {
    enum State {
        case Denied(AVAudioSessionRecordPermission)
        case Record, Stop, Play, Pause
    }
    
    var recordButtonState = State.Record {
        didSet {
            updateRecordShape()
        }
    }
    
    lazy var recordShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.redColor().colorWithAlphaComponent(0.65).CGColor
        layer.borderWidth = 0.0
        layer.position = CGPoint(x: 33.0, y: 33.0)
        
        self.layer.addSublayer(layer)
        return layer
    }()
    
    private func addRecordRing() {
        let effect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        let vibrancy = UIVisualEffectView(effect: effect)
        vibrancy.frame = self.bounds
        vibrancy.userInteractionEnabled = false
        addSubview(vibrancy)
        
        let ring = UIImage(named: "record_ring", inBundle: NSBundle(forClass: self.classForCoder), compatibleWithTraitCollection: nil)
        vibrancy.contentView.addSubview(UIImageView(image: ring))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addRecordRing()
        updateRecordShape()
        let bg = UIColor(red: 57.0/255.0, green: 57.0/255.0, blue: 56.0/255.0, alpha: 1.0)
        titleLabel?.font = UIFont.boldSystemFontOfSize(24)
        setTitleColor(bg, forState: .Normal)
    }
    
    override var tintColor: UIColor! {
        set {
            super.tintColor = newValue
            recordShape.fillColor = newValue.CGColor
        } get {
            return super.tintColor
        }
        
    }
    
    private func updateRecordShape() {
        let path: UIBezierPath
        var color: UIColor = self.tintColor
        var title = ""
        let a11y: String
        let a11yHint: String
        
        
        switch recordButtonState {
        case .Record:
            path = UIBezierPath(roundedRect: CGRectMake(-25, -25, 50, 50), cornerRadius: 25)
            color = UIColor.redColor()
            a11y = NSLocalizedString("Record", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Record button a11y label")
            a11yHint = NSLocalizedString("Begin recording", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "record button a11y hint")
        case .Stop:
            path = UIBezierPath(rect: CGRectMake(-12, -12, 24, 24))
            a11y = NSLocalizedString("Stop", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "stop recording button a11y label")
            a11yHint = NSLocalizedString("Begin recording", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "stop record button a11y hint")

        case .Play:
            path = UIBezierPath()
            path.moveToPoint(CGPoint(x: -12, y: -15))
            path.addLineToPoint(CGPoint(x: 18, y: 0))
            path.addLineToPoint(CGPoint(x: -12, y: 15))
            path.addLineToPoint(CGPoint(x: -12, y: -15))
            a11y = NSLocalizedString("Play", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Playback button")
            a11yHint = NSLocalizedString("Play back recording", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "play button a11y hint")
            
        case .Denied(let permission):
            path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0, y: -25))
            
            let x = CGFloat(25.0 * abs(cos(M_PI/6.0)))
            let y = CGFloat(25.0 * abs(sin(M_PI/6.0)))

            path.addLineToPoint(CGPoint(x: x, y: y))
            path.addLineToPoint(CGPoint(x: -x, y: y))
            path.addLineToPoint(CGPoint(x: 0, y: -25))
            color = UIColor.yellowColor()
            
            if permission == .Denied {
                title = "!"
                a11y = NSLocalizedString("Record Permission Help", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "permission denied button a11y label")
                a11yHint = NSLocalizedString("User has denied record permission", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "permission denied button a11y hint")
            } else {
                title = "?"
                a11y = NSLocalizedString("Request Audio Recording Permission", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Record button a11y label")
                a11yHint = NSLocalizedString("Request Permission to record audio", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "record button a11y hint")
            }
            
        case .Pause:
            path = UIBezierPath()
            path.appendPath(UIBezierPath(rect: CGRect(x: -12, y: -12, width: 8, height: 24)))
            path.appendPath(UIBezierPath(rect: CGRect(x: 4, y: -12, width: 8, height: 24)))
            a11y = NSLocalizedString("Pause", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Pause recording/playback")
            a11yHint = NSLocalizedString("Pause playback", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "record button a11y hint")
        }
        
        recordShape.path = path.CGPath
        recordShape.fillColor = color.CGColor
        setTitle(title, forState: .Normal)
        accessibilityIdentifier = a11y
        accessibilityLabel = a11y
        accessibilityHint = a11yHint
    }
}