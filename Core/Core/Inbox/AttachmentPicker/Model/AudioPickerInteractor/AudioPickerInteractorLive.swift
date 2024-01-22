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

class AudioPickerInteractorLive: AudioPickerInteractor {
    func intializeAudioRecorder(url: URL) throws -> CoreAVAudioRecorder {
        let recordingSession = AVAudioSession.sharedInstance()
        try recordingSession.setCategory(.record, mode: .default)
        try recordingSession.setActive(true)

        let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                ]

        return try CoreAVAudioRecorderLive(url: url, settings: settings)
    }
    
    func intializeAudioPlayer(url: URL) throws -> CoreAVAudioPlayer {
        let recordingSession = AVAudioSession.sharedInstance()
        try recordingSession.setCategory(.playback, mode: .default)
        try recordingSession.setActive(true)

        return try CoreAVAudioPlayerLive(contentsOf: url)
    }
}
