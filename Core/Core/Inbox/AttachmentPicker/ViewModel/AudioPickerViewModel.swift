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

    // MARK: Private
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var timer: Timer!
    private let formatter: DateComponentsFormatter
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    private var onSelect: (URL) -> Void

    // MARK: Outputs

    @Published public var isRecording: Bool = false
    @Published public var isRecorderLoading: Bool = false
    @Published public var loadingAnimationRotation = 0.0
    @Published public var isPlaying: Bool = false
    @Published public var isReplay: Bool = false
    @Published public var url: URL!
    @Published public var recordingLengthString: String = ""
    @Published public var audioPlayerPositionString: String = ""
    @Published public var audioPlayerPosition: Double = 0
    @Published public var audioPlayerDurationString: String = ""
    @Published public var audioPlotDataSet: [AudioPlotData] = []
    public let defaultDurationString: String

    // MARK: Inputs / Outputs

    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let useAudioButtonDidTap = PassthroughRelay<WeakViewController>()
    public let retakeButtonDidTap = PassthroughRelay<WeakViewController>()

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

    private func initRecorder() {
        DispatchQueue.main.async { [weak self] in
            self?.isRecorderLoading = true
        }
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Can not setup the Recording")
        }

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: getURL(), settings: settings)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        } catch {
            print("Failed to Setup the Recording")
        }
        DispatchQueue.main.async { [weak self] in
            self?.isRecorderLoading = false
        }
    }

    private func getURL() -> URL {
        let newUrl = URL.Directories.temporary.appendingPathComponent("\(UUID.string).m4a")
        url = newUrl
        return newUrl
    }

    func startRecording() {
        recordingLengthString = ""
        Task {
            initRecorder()

            audioRecorder.record()
            DispatchQueue.main.async { [weak self] in
                self?.isRecording = true
                self?.isRecorderLoading = false

                self?.recordingLengthString = self?.formatter.string(from: self?.audioRecorder.currentTime ?? 0) ?? ""
                self?.startTimer { [weak self] in
                    if let self {
                        let timeValue = self.audioRecorder.currentTime
                        self.recordingLengthString = self.formatter.string(from: timeValue) ?? ""
                        self.audioRecorder.updateMeters()
                        let powerValue = audioRecorder.peakPower(forChannel: 0)

                        audioPlotDataSet.append(AudioPlotData(timestamp: timeValue, value: powerValue))
                    }
                }
            }
        }
    }

    private func startTimer(action: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                action()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()

        isReplay = true
        initPlaying()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.currentTime = player.duration
        player.pause()
    }

    private func initPlaying() {
        do {
            let recordingSession = AVAudioSession.sharedInstance()
            try recordingSession.setCategory(.playback, mode: .default)
            try recordingSession.setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error while playing")
        }
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()

        audioPlayerDurationString = formatter.string(from: audioPlayer.duration) ?? ""

        startTimer { [weak self] in
            if let self {
                audioPlayerPosition = audioPlayer.currentTime
                audioPlayerPositionString = formatter.string(from: audioPlayer.currentTime) ?? ""
                isPlaying = audioPlayer.isPlaying
            }
        }
    }

    func seekInAudio(_ value: CGFloat) {
        var newValue = audioPlayer.currentTime - (value * 0.001)
        if newValue >= audioPlayer.duration - 0.1 {
            newValue = audioPlayer.duration - 0.1
        }
        audioPlayer.currentTime = newValue
        audioPlayerPosition = newValue
    }

    func startPlaying() {
        audioPlayer?.play()
        isPlaying = true
    }

    func pausePlaying() {
        audioPlayer?.pause()
        isPlaying = false
    }

    public func normalizeMeteringValue(rawValue: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let minValue: CGFloat = -50 // -160
        let maxValue: CGFloat = 0

        var shiftedRawValue = rawValue
        if rawValue < minValue {
            shiftedRawValue = minValue
        }

        let minBar: CGFloat = 3
        let maxBar: CGFloat = maxHeight

        let newValue = minBar + (maxBar - minBar) / (maxValue - minValue) * (shiftedRawValue - minValue)
        return newValue
    }

    private func setupInputBindings(router: Router) {
        cancelButtonDidTap
            .sink { [weak self, router] viewController in
                self?.audioRecorder?.stop()
                self?.audioPlayer?.stop()
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

        retakeButtonDidTap
            .sink { [weak self] _ in
                if let self {
                    self.audioPlayer?.stop()
                    self.isReplay = false
                    self.audioPlotDataSet = []
                }
            }
            .store(in: &subscriptions)
    }

}
