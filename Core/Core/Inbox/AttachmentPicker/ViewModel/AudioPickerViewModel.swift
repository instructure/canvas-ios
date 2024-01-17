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
import AVFoundation
import Combine
import CombineExt

class AudioPickerViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var timer: Timer!
    private let formatter: DateComponentsFormatter
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    public var onSelect: (URL) -> Void

    @Published public var isRecording: Bool = false
    @Published public var isPlaying: Bool = false
    @Published public var availableForPlaying: Bool = false
    @Published public var url: URL!
    @Published public var recordingDurationString: String = ""
    @Published public var playingDurationString: String = ""
    public let defaultDurationString: String

    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let useAudioButtonDidTap = PassthroughRelay<WeakViewController>()

    public init(router: Router, onSelect: @escaping (URL) -> Void = { _ in }) {
        self.router = router
        self.onSelect = onSelect

        formatter = DateComponentsFormatter()
        formatter.allowedUnits = [. hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad

        defaultDurationString = formatter.string(from: 0) ?? ""

        super.init()
        setupInputBindings(router: router)
    }

    func startRecording() {
        recordingDurationString = ""
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Can not setup the Recording")
        }

        url = URL.Directories.temporary.appendingPathComponent("\(UUID.string).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true

            recordingDurationString = formatter.string(from: audioRecorder.currentTime) ?? ""
            startTimer { [weak self] in
                if let self {
                    self.recordingDurationString = self.formatter.string(from: self.audioRecorder.currentTime) ?? ""
                }
            }
        } catch {
            print("Failed to Setup the Recording")
        }
    }

    private func startTimer(action: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                action()
            }
        }
    }

    private func stopTimer() {
        timer.invalidate()
    }

    func stopRecording() {
        audioRecorder.stop()
        isRecording = false
        stopTimer()

        availableForPlaying = true
    }

    func startPlaying() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error while playing")
        }
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        isPlaying = true

        startTimer { [weak self] in
            if let self {
                self.playingDurationString = self.formatter.string(from: self.audioPlayer.currentTime) ?? ""
            }
        }
    }

    func pausePlaying() {
        audioPlayer?.pause()
        isPlaying = false
    }

    private func setupInputBindings(router: Router) {
        cancelButtonDidTap
            .sink { [router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        useAudioButtonDidTap
            .sink { [weak self, router] viewController in
                if let url = self?.url {
                    self?.onSelect(url)
                }
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }

}
