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
    
    

import UIKit
import AVFoundation


class RecordButton: UIButton {
    enum State {
        case denied(AVAudioSessionRecordPermission)
        case record, stop, play, pause
    }
    
    var recordButtonState = State.record {
        didSet {
            updateRecordShape()
        }
    }
    
    lazy var recordShape: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.red.withAlphaComponent(0.65).cgColor
        layer.borderWidth = 0.0
        layer.position = CGPoint(x: 33.0, y: 33.0)
        
        self.layer.addSublayer(layer)
        return layer
    }()
    
    fileprivate func addRecordRing() {
        let effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
        let vibrancy = UIVisualEffectView(effect: effect)
        vibrancy.frame = self.bounds
        vibrancy.isUserInteractionEnabled = false
        addSubview(vibrancy)
        
        let ring = UIImage(named: "record_ring", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        vibrancy.contentView.addSubview(UIImageView(image: ring))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addRecordRing()
        updateRecordShape()
        let bg = UIColor(red: 57.0/255.0, green: 57.0/255.0, blue: 56.0/255.0, alpha: 1.0)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        setTitleColor(bg, for: UIControlState())
    }
    
    override var tintColor: UIColor! {
        set {
            super.tintColor = newValue
            recordShape.fillColor = newValue.cgColor
        } get {
            return super.tintColor
        }
        
    }
    
    fileprivate func updateRecordShape() {
        let path: UIBezierPath
        var color: UIColor = self.tintColor
        var title = ""
        let a11y: String
        let a11yHint: String
        
        
        switch recordButtonState {
        case .record:
            path = UIBezierPath(roundedRect: CGRect(x: -25, y: -25, width: 50, height: 50), cornerRadius: 25)
            color = UIColor.red
            a11y = NSLocalizedString("Record", tableName: "Localizable", bundle: .core, value: "", comment: "Record button a11y label")
            a11yHint = NSLocalizedString("Begin recording", tableName: "Localizable", bundle: .core, value: "", comment: "stop record button a11y hint")
        case .stop:
            path = UIBezierPath(rect: CGRect(x: -12, y: -12, width: 24, height: 24))
            a11y = NSLocalizedString("Stop", tableName: "Localizable", bundle: .core, value: "", comment: "stop recording button a11y label")
            a11yHint = NSLocalizedString("Begin recording", tableName: "Localizable", bundle: .core, value: "", comment: "stop record button a11y hint")

        case .play:
            path = UIBezierPath()
            path.move(to: CGPoint(x: -12, y: -15))
            path.addLine(to: CGPoint(x: 18, y: 0))
            path.addLine(to: CGPoint(x: -12, y: 15))
            path.addLine(to: CGPoint(x: -12, y: -15))
            a11y = NSLocalizedString("Play", tableName: "Localizable", bundle: .core, value: "", comment: "Playback button")
            a11yHint = NSLocalizedString("Play back recording", tableName: "Localizable", bundle: .core, value: "", comment: "play button a11y hint")
            
        case .denied(let permission):
            path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: -25))
            
            let x = CGFloat(25.0 * abs(cos(.pi/6.0)))
            let y = CGFloat(25.0 * abs(sin(.pi/6.0)))

            path.addLine(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: -x, y: y))
            path.addLine(to: CGPoint(x: 0, y: -25))
            color = UIColor.yellow
            
            if permission == .denied {
                title = "!"
                a11y = NSLocalizedString("Record Permission Help", tableName: "Localizable", bundle: .core, value: "", comment: "permission denied button a11y label")
                a11yHint = NSLocalizedString("User has denied record permission", tableName: "Localizable", bundle: .core, value: "", comment: "permission denied button a11y hint")
            } else {
                title = "?"
                a11y = NSLocalizedString("Request Audio Recording Permission", tableName: "Localizable", bundle: .core, value: "", comment: "Record button a11y label")
                a11yHint = NSLocalizedString("Request Permission to record audio", tableName: "Localizable", bundle: .core, value: "", comment: "stop record button a11y hint")
            }
            
        case .pause:
            path = UIBezierPath()
            path.append(UIBezierPath(rect: CGRect(x: -12, y: -12, width: 8, height: 24)))
            path.append(UIBezierPath(rect: CGRect(x: 4, y: -12, width: 8, height: 24)))
            a11y = NSLocalizedString("Pause", tableName: "Localizable", bundle: .core, value: "", comment: "Pause recording/playback")
            a11yHint = NSLocalizedString("Pause playback", tableName: "Localizable", bundle: .core, value: "", comment: "record button a11y hint")
        }
        
        recordShape.path = path.cgPath
        recordShape.fillColor = color.cgColor
        setTitle(title, for: UIControlState())
        accessibilityIdentifier = a11y
        accessibilityLabel = a11y
        accessibilityHint = a11yHint
    }
}
