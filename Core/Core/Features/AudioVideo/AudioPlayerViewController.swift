//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import AVKit
import Foundation

public class AudioPlayerViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView?
    @IBOutlet weak var currentTimeLabel: DynamicLabel?
    @IBOutlet weak var loadingView: UIActivityIndicatorView?
    @IBOutlet weak var playPauseButton: DynamicButton?
    @IBOutlet weak var remainingTimeLabel: DynamicLabel?
    @IBOutlet weak var thumb: UIView?
    @IBOutlet weak var timeSlider: UISlider?
    @IBOutlet weak var track: UIView?
    @IBOutlet weak var trackFill: UIView?
    @IBOutlet weak var trackFillWidth: NSLayoutConstraint?

    lazy var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var player: AVAudioPlayer?
    var timer: CADisplayLink?
    var url: URL?

    public static func create() -> AudioPlayerViewController {
        let controller = loadFromStoryboard()
        controller.loadViewIfNeeded() // So the didSets work correctly.
        controller.color = .textLightest // trigger didSet
        return controller
    }

    public var accessibilityPrefix: String = "AudioPlayer." {
        didSet {
            currentTimeLabel?.accessibilityIdentifier = currentTimeLabel?.accessibilityIdentifier?.replacingOccurrences(of: oldValue, with: accessibilityPrefix)
            loadingView?.accessibilityIdentifier = loadingView?.accessibilityIdentifier?.replacingOccurrences(of: oldValue, with: accessibilityPrefix)
            playPauseButton?.accessibilityIdentifier = playPauseButton?.accessibilityIdentifier?.replacingOccurrences(of: oldValue, with: accessibilityPrefix)
            remainingTimeLabel?.accessibilityIdentifier = remainingTimeLabel?.accessibilityIdentifier?.replacingOccurrences(of: oldValue, with: accessibilityPrefix)
            timeSlider?.accessibilityIdentifier = timeSlider?.accessibilityIdentifier?.replacingOccurrences(of: oldValue, with: accessibilityPrefix)
        }
    }

    public var backgroundColor: UIColor? {
        get { return backgroundView?.backgroundColor }
        set { backgroundView?.backgroundColor = newValue }
    }

    public var color: UIColor = .textLightest {
        didSet {
            currentTimeLabel?.textColor = color
            loadingView?.color = color
            playPauseButton?.tintColor = color
            remainingTimeLabel?.textColor = color
            thumb?.backgroundColor = color
            track?.backgroundColor = color.withAlphaComponent(0.5)
            trackFill?.backgroundColor = color.withAlphaComponent(0.5)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        backgroundColor = .backgroundDarkest
        playPauseButton?.accessibilityLabel = String(localized: "Play", bundle: .core)
        currentTimeLabel?.accessibilityLabel = String(localized: "Time elapsed", bundle: .core)
        loadingView?.accessibilityIdentifier = "AudioPlayer.loadingView"
        loadingView?.color = color
        remainingTimeLabel?.accessibilityLabel = String(localized: "Total time", bundle: .core)
        timeSlider?.accessibilityLabel = String(localized: "Current position", bundle: .core)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pause()
    }

    public func load(url: URL?) {
        self.url = url
        currentTimeLabel?.text = String(localized: "--:--", bundle: .core, comment: "Unknown time duration")
        remainingTimeLabel?.text = String(localized: "--:--", bundle: .core, comment: "Unknown time duration")
        loadingView?.startAnimating()
        playPauseButton?.alpha = 0
        playPauseButton?.isEnabled = false
        guard let url = url else { return }
        API(urlSession: .shared).makeRequest(url) { [weak self] data, _, error in performUIUpdate {
            guard error == nil, let data = data else {
                self?.showError(error ?? NSError.internalError())
                return
            }
            self?.loadData(data)
        } }
    }

    public func loadData(_ data: Data) {
        loadingView?.stopAnimating()
        playPauseButton?.alpha = 1
        playPauseButton?.isEnabled = true
        do {
            player = try AVAudioPlayer(data: data)
            player?.delegate = self
            tick()
        } catch {
            showError(error)
        }
    }

    func showError(_ error: Error) {
        // TODO: propagate to embedder?
        print(error.localizedDescription)
    }

    public func play() {
        guard let player = player else { return }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            if player.play() {
                playPauseButton?.setImage(.pauseSolid, for: .normal)
                playPauseButton?.accessibilityLabel = String(localized: "Pause", bundle: .core)
                timer = CADisplayLink(target: self, selector: #selector(tick))
                timer?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            }
        } catch {
            showError(error)
        }
    }

    @objc func tick(_ timer: CADisplayLink? = nil) {
        guard let player = player else { return }
        currentTimeLabel?.text = formatTime(player.currentTime)
        remainingTimeLabel?.text = formatTime(player.duration)
        timeSlider?.accessibilityValue = currentTimeLabel?.text
        timeSlider?.maximumValue = Float(player.duration)
        timeSlider?.setValue(Float(player.currentTime), animated: false)
        trackFillWidth?.constant = (track?.frame.width ?? 0) * CGFloat(player.currentTime / player.duration)
    }

    @IBAction func scrub(_ timeSlider: UISlider) {
        guard let player = player else { return }
        player.currentTime = TimeInterval(timeSlider.value)
        tick()
    }

    public func pause() {
        guard let player = player else { return }
        timer?.invalidate()
        timer = nil
        player.stop()
        playPauseButton?.setImage(.playSolid, for: .normal)
        playPauseButton?.accessibilityLabel = String(localized: "Play", bundle: .core)
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    @IBAction func playPause(_ sender: UIButton) {
        if player?.isPlaying == true {
            pause()
        } else {
            play()
        }
    }

    private func formatTime(_ value: TimeInterval) -> String? {
        let correctValue = value.isFinite ? value : 0
        return formatter.string(from: correctValue)
    }
}

extension AudioPlayerViewController: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        pause()
        player.currentTime = 0
        tick()
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        pause()
        if let error = error { showError(error) }
    }
}
