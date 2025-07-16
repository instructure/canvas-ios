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

class CoreAVAudioRecorderLive: CoreAVAudioRecorder {
    let audioRecorder: AVAudioRecorder

    var currentTime: TimeInterval {
        audioRecorder.currentTime
    }

    var isMeteringEnabled: Bool {
        get {
            audioRecorder.isMeteringEnabled
        }
        set(newVal) {
            audioRecorder.isMeteringEnabled = newVal
        }
    }

    required init(url: URL, settings: [String: Int]) throws {
        self.audioRecorder = try AVAudioRecorder(url: url, settings: settings)
    }

    func prepareToRecord() {
        audioRecorder.prepareToRecord()
    }

    func record() {
        audioRecorder.record()
    }

    func updateMeters() {
        audioRecorder.updateMeters()
    }

    func peakPower(forChannel channelNumber: Int) -> Float {
        audioRecorder.peakPower(forChannel: channelNumber)
    }

    func stop() {
        audioRecorder.stop()
    }

}
