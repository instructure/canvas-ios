//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import AVFAudio

class CoreAVAudioPlayerLive: CoreAVAudioPlayer {
    private let audioPlayer: AVAudioPlayer

    private(set) var isPrepareToPlayCalled: Bool = false
    private(set) var isPlayCalled: Bool = false
    private(set) var isPauseCalled: Bool = false
    private(set) var isStopCalled: Bool = false

    var duration: TimeInterval {
        audioPlayer.duration
    }
    var currentTime: TimeInterval {
        get {
            audioPlayer.currentTime
        }
        set(newValue) {
            audioPlayer.currentTime = newValue
        }
    }
    var delegate: AVAudioPlayerDelegate? {
        get {
            audioPlayer.delegate
        }
        set(newValue) {
            audioPlayer.delegate = newValue
        }
    }
    var isPlaying: Bool {
        audioPlayer.isPlaying
    }

    required init(contentsOf url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
    }

    func prepareToPlay() {
        audioPlayer.prepareToPlay()
    }

    func play() {
        audioPlayer.play()
    }

    func pause() {
        audioPlayer.pause()
    }

    func stop() {
        audioPlayer.stop()
    }
}
