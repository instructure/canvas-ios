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

#if DEBUG

import Foundation
import Combine

public class AudioPickerInteractorPreview: AudioPickerInteractor {

    public var audioRecorder: CoreAVAudioRecorder? = CoreAVAudioRecorderPreview()
    public var audioPlayer: CoreAVAudioPlayer? = CoreAVAudioPlayerPreview()
    public var url: URL? = URL.Directories.temporary
    public var recorderTimer = PassthroughSubject<AudioPlotData, Error>()
    public var playerTimer = PassthroughSubject<TimeInterval, Error>()
    public var playerFinished = PassthroughSubject<Void, Never>()
    public var seekInAudioCalled: Bool = false

    public func seekInAudio(newValue: CGFloat) {
        seekInAudioCalled = true
    }

    public func startRecording() {
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
    }

    public func stopRecording() {
        audioRecorder?.stop()
        audioPlayer?.prepareToPlay()
    }

    public func playAudio() {
        audioPlayer?.play()
    }

    public func pauseAudio() {
        audioPlayer?.pause()
    }

    public func stopAudio() {
        audioPlayer?.stop()
    }

    public func cancel() {
        audioPlayer?.stop()
        audioRecorder?.stop()
    }

    public func retakeAudio() {

    }

    public func throwRecorderError() {
        recorderTimer.send(completion: .failure(NSError.instructureError("Failed to record audio")))
    }

    public func throwPlayerError() {
        playerTimer.send(completion: .failure(NSError.instructureError("Failed to play audio")))
    }
}

#endif
