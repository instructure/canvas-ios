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
