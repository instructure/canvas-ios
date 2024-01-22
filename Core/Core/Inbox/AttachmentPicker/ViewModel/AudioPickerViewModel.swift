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

    @Published public private(set) var isRecording: Bool = false
    @Published public private(set) var isRecorderLoading: Bool = false
    @Published public var loadingAnimationRotation = 0.0
    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var isReplay: Bool = false
    @Published public private(set) var url: URL!
    @Published public private(set) var recordingLengthString: String = ""
    @Published public private(set) var audioPlayerPositionString: String = ""
    @Published public private(set) var audioPlayerPosition: Double = 0
    @Published public private(set) var audioPlayerDurationString: String = ""
    @Published public private(set) var audioPlotDataSet: [AudioPlotData] = []
    public let defaultDurationString: String
    public let audioRecorderErrorTitle = NSLocalizedString("Error", comment: "")
    public let audioRecorderErrorMessage = NSLocalizedString("Some error occured with audio recorder. Please try again!", comment: "")

    // MARK: Inputs / Outputs

    public let cancelButtonDidTap = PassthroughRelay<WeakViewController>()
    public let useAudioButtonDidTap = PassthroughRelay<WeakViewController>()
    public let retakeButtonDidTap = PassthroughRelay<WeakViewController>()
    public let recordAudioButtonDidTap = PassthroughRelay<WeakViewController>()
    public let stopRecordAudioButtonDidTap = PassthroughRelay<WeakViewController>()
    public let playAudioButtonDidTap = PassthroughRelay<WeakViewController>()
    public let pauseAudioButtonDidTap = PassthroughRelay<WeakViewController>()

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

    private func showAudioErrorDialog() {
        let actionTitle = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title: audioRecorderErrorTitle, message: audioRecorderErrorMessage, preferredStyle: .alert)

        if let top = AppEnvironment.shared.window?.rootViewController?.topMostViewController() {
            let action = UIAlertAction(title: actionTitle, style: .default) { _ in
                top.dismiss(animated: false)
            }
            alert.addAction(action)
            router.show(alert, from: top, options: .modal())
        }
    }

    private func startTimer(action: @escaping () -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                action()
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.currentTime = player.duration
        player.pause()
    }

    func seekInAudio(_ value: CGFloat) {
        var newValue = audioPlayer.currentTime - (value * 0.001)
        if newValue >= audioPlayer.duration - 0.1 {
            newValue = audioPlayer.duration - 0.1
        }
        audioPlayer.currentTime = newValue
        audioPlayerPosition = newValue
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
            .sink { [weak self] _ in
                if let url = self?.url {
                    self?.onSelect(url)
                }
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

        recordAudioButtonDidTap
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isRecorderLoading = true
            })
            .tryMap { [weak self] _ in
                let newUrl = URL.Directories.temporary.appendingPathComponent("\(UUID.string).m4a")

                let recordingSession = AVAudioSession.sharedInstance()

                try recordingSession.setCategory(.record, mode: .default)
                try recordingSession.setActive(true)

                let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                        ]

                self?.audioRecorder = try AVAudioRecorder(url: newUrl, settings: settings)
                self?.audioRecorder.isMeteringEnabled = true
                self?.audioRecorder.prepareToRecord()

                return newUrl
            }
            .tryCatch { _ in Just(URL.Directories.caches) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in self?.showAudioErrorDialog() },
                receiveValue: { [weak self] url in
                    self?.url = url
                    self?.isRecording = true
                    self?.isRecorderLoading = false
                    self?.audioRecorder.record()

                    self?.recordingLengthString = self?.formatter.string(from: self?.audioRecorder.currentTime ?? 0) ?? ""
                    self?.startTimer { [weak self] in
                        let timeValue = self?.audioRecorder.currentTime ?? 0
                        self?.recordingLengthString = self?.formatter.string(from: timeValue) ?? ""
                        self?.audioRecorder.updateMeters()
                        let powerValue = self?.audioRecorder.peakPower(forChannel: 0) ?? 0

                        self?.audioPlotDataSet.append(AudioPlotData(timestamp: timeValue, value: powerValue))
                    }
                }
             )
            .store(in: &subscriptions)

        stopRecordAudioButtonDidTap
            .tryMap { [weak self] _ in
                self?.audioRecorder?.stop()
                self?.timer?.invalidate()
                let recordingSession = AVAudioSession.sharedInstance()
                try recordingSession.setCategory(.playback, mode: .default)
                try recordingSession.setActive(true)
                if let self {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: self.url )
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.audioRecorder?.stop()
                    self?.showAudioErrorDialog()
                },
                receiveValue: { [weak self] in
                    self?.isRecording = false
                    self?.isReplay = true
                    self?.audioPlayer?.delegate = self
                    self?.audioPlayer?.prepareToPlay()
                    self?.audioPlayerDurationString = self?.formatter.string(from: self?.audioPlayer.duration ?? 0) ?? ""
                    self?.audioPlayerPosition = self?.audioPlayer.currentTime ?? 0
                    self?.audioPlayerPositionString = self?.formatter.string(from: self?.audioPlayer.currentTime ?? 0) ?? ""
                }
            )
            .store(in: &subscriptions)

        playAudioButtonDidTap
            .sink { [weak self] _ in
                self?.audioPlayer?.play()
                self?.isPlaying = true

                self?.startTimer { [weak self] in
                    if let self {
                        audioPlayerPosition = audioPlayer.currentTime
                        audioPlayerPositionString = formatter.string(from: audioPlayer.currentTime) ?? ""
                        isPlaying = audioPlayer.isPlaying
                    }
                }
            }
            .store(in: &subscriptions)

        pauseAudioButtonDidTap
            .sink { [weak self] _ in
                self?.audioPlayer?.pause()
                self?.isPlaying = false
            }
            .store(in: &subscriptions)
    }

}
