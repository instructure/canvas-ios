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


class PlaybackScrubber: UIControl {
    fileprivate var duration: TimeInterval = 1.0
    var currentTime: TimeInterval = 0.0001
    
    @IBOutlet var trackView: UIView!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    
    lazy var scrubber: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 2, height: 15)
        layer.backgroundColor = self.tintColor.cgColor
        layer.cornerRadius = 1.0
        self.layer.addSublayer(layer)
        return layer
    }()
    
    func update(_ duration: TimeInterval, currentTime: TimeInterval) {
        if scrubbingTime != nil {
            return
        }
        
        self.duration = duration
        self.currentTime = currentTime
        
        updateUI()
    }
    
    override func awakeFromNib() {
        let scrub = UILongPressGestureRecognizer(target: self, action: #selector(PlaybackScrubber.scrubGesture(_:)))
        scrub.minimumPressDuration = 0.0
        addGestureRecognizer(scrub)
        
        updateUI()
    }
    
    
    var scrubbingTime: TimeInterval?
    func scrubGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchPoint = gesture.location(in: self)
            
            if abs(touchPoint.x - scrubberPosition.x) < 24 {
                let x = gesture.location(in: trackView).x
                scrubbingTime = Double(x / trackView.bounds.width) * duration
                updateUI()
            }
        case .changed:
            if scrubbingTime != nil {
                let x = gesture.location(in: trackView).x
                let normalized = max(0.0, min(1.0, Double(x / trackView.bounds.width)))
                scrubbingTime = normalized * duration
                updateUI()
            }
        case .ended:
            if let scrubbingTime = scrubbingTime {
                currentTime = scrubbingTime
                sendActions(for: .valueChanged)
            }
            fallthrough
        default:
            scrubbingTime = nil
        }
    }
    
    var scrubberPosition: CGPoint {
        var track = convert(trackView.frame, from: trackView.superview)
        let scrub = scrubber.frame
        track.size.width -= scrub.size.width
        track.origin.x += scrub.size.width/2.0
        
        let y = track.origin.y + track.height/2.0
        let t = scrubbingTime ?? currentTime
        let x = track.origin.x + track.width * CGFloat(t/duration)
     
        return CGPoint(x: x, y: y)
    }
    
    func updateUI() {
        updateScrubberPosition()
        updateLabels()
    }
    
    func updateScrubberPosition() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        scrubber.position = scrubberPosition
        CATransaction.commit()
    }
    
    func updateLabels() {
        let t = scrubbingTime ?? currentTime
        currentTimeLabel.text = t.formatted()
        let remaining = (duration - t)
        timeRemainingLabel.text = "-" + remaining.formatted()
    }
}
