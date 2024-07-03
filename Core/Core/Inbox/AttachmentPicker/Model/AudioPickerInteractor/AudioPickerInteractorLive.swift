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
import Combine

class AudioPickerInteractorLive: NSObject, AudioPickerInteractor {

    public private(set) var url: URL?
    public private(set) var audioRecorder: CoreAVAudioRecorder?
    public private(set) var audioPlayer: CoreAVAudioPlayer?

    let recorderTimer = PassthroughSubject<AudioPlotData, Error>()
    let playerTimer = PassthroughSubject<TimeInterval, Error>()
    var playerFinished = PassthroughSubject<Void, Never>()

    private var recorderCancellable: Cancellable?
    private var playerCancellable: Cancellable?

    func seekInAudio(newValue: CGFloat) {
        audioPlayer?.currentTime = newValue
    }

    func startRecording() {
        url = getAudioUrl()

        if let url, let recorder = try? initializeAudioRecorder(url: url) {
            audioRecorder = recorder
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
        } else {
            recorderTimer.send(completion: .failure(NSError.instructureError("Failed to record audio")))
        }

        recorderCancellable?.cancel()
        recorderCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .map { [weak self] _ -> AudioPlotData in
                let timestamp = self?.audioRecorder?.currentTime ?? 0

                self?.audioRecorder?.updateMeters()
                let peakPower = self?.audioRecorder?.peakPower(forChannel: 0) ?? 0

                return AudioPlotData(timestamp: timestamp, value: peakPower)
            }
            .map { [weak self] audioData in
                self?.recorderTimer.send(audioData)
            }
            .sink()
    }

    func stopRecording() {
        recorderCancellable?.cancel()
        audioRecorder?.stop()

        if let url, var player = try? initializeAudioPlayer(url: url) {
            audioPlayer = player
            player.delegate = self
            player.prepareToPlay()
        } else {
            recorderTimer.send(completion: .failure(NSError.instructureError("Failed to play audio")))
        }

        playerCancellable?.cancel()
        playerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .map { [weak self] _ in
                return self?.audioPlayer?.currentTime ?? 0
            }
            .map { [weak self] time in
                self?.playerTimer.send(time)
            }
            .sink()
    }

    func playAudio() {
        audioPlayer?.play()
    }

    func pauseAudio() {
        audioPlayer?.pause()
    }

    func stopAudio() {
        audioPlayer?.stop()
        playerCancellable?.cancel()
    }

    func cancel() {
        audioPlayer?.stop()
        audioRecorder?.stop()
        playerCancellable?.cancel()
        recorderCancellable?.cancel()
    }

    func retakeAudio() {
        cancel()
    }

    // MARK: Private helpers

    private func initializeAudioRecorder(url: URL) throws -> CoreAVAudioRecorder {
        let recordingSession = AVAudioSession.sharedInstance()
        try recordingSession.setCategory(.record, mode: .default)
        try recordingSession.setActive(true)

        let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]

        let audioRecorder = try CoreAVAudioRecorderLive(url: url, settings: settings)
        audioRecorder.isMeteringEnabled = true

        return audioRecorder
    }

    private func initializeAudioPlayer(url: URL) throws -> CoreAVAudioPlayer {
        let recordingSession = AVAudioSession.sharedInstance()
        try recordingSession.setCategory(.playback, mode: .default)
        try recordingSession.setActive(true)

        return try CoreAVAudioPlayerLive(contentsOf: url)
    }

    private func getAudioUrl() -> URL {
        return URL.Directories.temporary.appendingPathComponent("\(UUID.string).m4a")
    }
}

extension AudioPickerInteractorLive: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.playerFinished.send(())
        }
    }
}
