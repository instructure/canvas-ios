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
    @Published public private(set) var recordingLengthString: String = ""
    @Published public private(set) var audioPlayerPositionString: String = ""
    @Published public private(set) var audioPlayerPosition: TimeInterval = 0
    @Published public private(set) var audioPlayerDurationString: String = ""
    var audioChartDataSet: [AudioPlotData] = []
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
    public let interactor: AudioPickerInteractor

    public init(router: Router, interactor: AudioPickerInteractor, onSelect: @escaping (URL) -> Void = { _ in }) {
        self.router = router
        self.onSelect = onSelect
        self.interactor = interactor

        formatter = DateComponentsFormatter()
        formatter.allowedUnits = [. hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad

        defaultDurationString = formatter.string(from: 0) ?? ""

        super.init()

        setupControlBindings(router: router)
        setupRecordBindings(interactor: interactor)
        setupPlaybackBindings()
        setupOutputBindings()
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

    func seekInAudio(_ value: CGFloat) {
        let newValue = normalizeSeekValue(rawValue: value)
        interactor.seekInAudio(newValue: newValue)
    }

    func normalizeSeekValue(rawValue value: CGFloat) -> CGFloat {
        if let audioPlayer = interactor.audioPlayer {
            var newValue = audioPlayer.currentTime - (value * 0.001)
            if newValue >= audioPlayer.duration - 0.1 {
                newValue = audioPlayer.duration - 0.1
            }
            return newValue
        }
        return 0
    }

    func normalizeMeteringValue(rawValue: CGFloat, maxHeight: CGFloat) -> CGFloat {
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

    private func setupOutputBindings() {
        interactor.recorderTimer
            .sink(receiveCompletion: { [weak self] _ in
                self?.showAudioErrorDialog()
            }, receiveValue: { [weak self] audioData in
                    self?.audioChartDataSet.append(audioData)
                    self?.recordingLengthString = self?.formatTimestamp(timestamp: audioData.timestamp) ?? ""
            })
            .store(in: &subscriptions)

        interactor.playerTimer
            .sink(receiveCompletion: { [weak self] _ in
                self?.showAudioErrorDialog()
            }, receiveValue: { [weak self] timestamp in
                self?.audioPlayerPosition = timestamp
                self?.audioPlayerPositionString = self?.formatTimestamp(timestamp: timestamp) ?? ""

            })
            .store(in: &subscriptions)
    }

    private func formatTimestamp(timestamp: TimeInterval?) -> String {
        formatter.string(from: timestamp ?? 0) ?? ""
    }

    private func setupControlBindings(router: Router) {
        cancelButtonDidTap
            .sink { [weak self, router] viewController in
                self?.interactor.cancel()
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        useAudioButtonDidTap
            .sink { [weak self] _ in
                if let url = self?.interactor.url {
                    self?.onSelect(url)
                }
            }
            .store(in: &subscriptions)

        retakeButtonDidTap
            .sink { [weak self] _ in
                self?.interactor.retakeAudio()
                self?.isReplay = false
                self?.audioChartDataSet = []
            }
            .store(in: &subscriptions)
    }

    private func setupRecordBindings(interactor: AudioPickerInteractor) {
        recordAudioButtonDidTap
            .sink { [weak self] _ in
                self?.interactor.startRecording()
                self?.isRecording = true
            }
            .store(in: &subscriptions)

        stopRecordAudioButtonDidTap
            .sink { [weak self] _ in
                self?.interactor.stopRecording()
                self?.isRecording = false
                self?.isReplay = true
                self?.audioPlayerDurationString = self?.formatTimestamp(timestamp: self?.interactor.audioPlayer?.duration) ?? ""
            }
            .store(in: &subscriptions)
    }

    private func setupPlaybackBindings() {
        playAudioButtonDidTap
            .sink { [weak self] _ in
                self?.interactor.playAudio()
                self?.isPlaying = true
            }
            .store(in: &subscriptions)

        pauseAudioButtonDidTap
            .sink { [weak self] _ in
                self?.interactor.pauseAudio()
                self?.isPlaying = false
            }
            .store(in: &subscriptions)
    }

}
