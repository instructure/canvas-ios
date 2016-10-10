//
//  AudioPlayer.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 9/3/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerDelegate {
    func player(player: AudioPlayer, finishedWithError: NSError?)
    func player(player: AudioPlayer, progressUpdatedWithCurrentTime currentTime: NSTimeInterval, meter: Int)
}

class AudioPlayer: NSObject {
    let audioFileURL: NSURL
    private let meterTable: MeterTable
    private var player: AVAudioPlayer?
    
    private var timer: CADisplayLink?
    
    var delegate: AudioPlayerDelegate? {
        didSet {
            sendUpdate()
        }
    }
    
    init(audioFileURL: NSURL, ticks: Int) throws {
        self.audioFileURL = audioFileURL
        self.meterTable = MeterTable(meterTicks: ticks)
        
        super.init()
        
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try AVAudioSession.sharedInstance().setActive(true)
        
        
        let player = try AVAudioPlayer(contentsOfURL: audioFileURL)
        player.volume = 1.0
        player.numberOfLoops = 0
        player.delegate = self
        player.meteringEnabled = true
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
        timer?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
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
    
    var currentTime: NSTimeInterval {
        get {
            return player?.currentTime ?? 0.0
        } set {
            player?.currentTime = newValue
        }
    }
    
    var duration: NSTimeInterval {
        return player?.duration ?? 0.0
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        delegate?.player(self, finishedWithError: error)

        ceaseUpdates()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.player(self, finishedWithError: nil)

        ceaseUpdates()
    }
}

extension AudioPlayer {
    private func sendUpdate() {
        if let p = player, delegate = delegate {
            p.updateMeters()
            let peak0 = p.averagePowerForChannel(0)
            let peak1 = p.averagePowerForChannel(1)
            let avgPeak = (peak0 + peak1) / 2.0
            let meter = meterTable[Double(avgPeak)]
            
            delegate.player(self, progressUpdatedWithCurrentTime: currentTime, meter: meter)
        }
    }
    
    func timerFired(timer: CADisplayLink) {
        sendUpdate()
    }
}
