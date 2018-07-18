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
import AVFoundation

protocol AudioPlayerDelegate {
    func player(_ player: AudioPlayer, finishedWithError: NSError?)
    func player(_ player: AudioPlayer, progressUpdatedWithCurrentTime currentTime: TimeInterval, meter: Int)
}

class AudioPlayer: NSObject {
    let audioFileURL: URL
    fileprivate let meterTable: MeterTable
    fileprivate var player: AVAudioPlayer?
    
    fileprivate var timer: CADisplayLink?
    
    var delegate: AudioPlayerDelegate? {
        didSet {
            sendUpdate()
        }
    }
    
    init(audioFileURL: URL, ticks: Int) throws {
        self.audioFileURL = audioFileURL
        self.meterTable = MeterTable(meterTicks: ticks)
        
        super.init()
        
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try AVAudioSession.sharedInstance().setActive(true)
        
        
        let player = try AVAudioPlayer(contentsOf: audioFileURL)
        player.volume = 1.0
        player.numberOfLoops = 0
        player.delegate = self
        player.isMeteringEnabled = true
        self.player = player
    }
    
    deinit {
        ceaseUpdates()
        player?.delegate = nil
        player?.stop()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
            
        }
    }
    
    func play() {
        player?.play()
        
        timer = CADisplayLink(target: self, selector: #selector(AudioPlayer.timerFired(_:)))
        timer?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    func pause() {
        player?.pause()
        sendUpdate()
        ceaseUpdates()
    }
    
    func ceaseUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    var currentTime: TimeInterval {
        get {
            return player?.currentTime ?? 0.0
        } set {
            player?.currentTime = newValue
        }
    }
    
    var duration: TimeInterval {
        return player?.duration ?? 0.0
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        delegate?.player(self, finishedWithError: error as NSError?)

        ceaseUpdates()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.player(self, finishedWithError: nil)

        ceaseUpdates()
    }
}

extension AudioPlayer {
    fileprivate func sendUpdate() {
        if let p = player, let delegate = delegate {
            p.updateMeters()
            let peak0 = p.averagePower(forChannel: 0)
            let peak1 = p.averagePower(forChannel: 1)
            let avgPeak = (peak0 + peak1) / 2.0
            let meter = meterTable[Double(avgPeak)]
            
            delegate.player(self, progressUpdatedWithCurrentTime: currentTime, meter: meter)
        }
    }
    
    func timerFired(_ timer: CADisplayLink) {
        sendUpdate()
    }
}
