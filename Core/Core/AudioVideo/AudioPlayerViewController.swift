//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

    public static func create() -> AudioPlayerViewController {
        let controller = loadFromStoryboard()
        return controller
    }

    public var backgroundColor: UIColor? {
        get { return backgroundView?.backgroundColor }
        set {
            loadViewIfNeeded()
            backgroundView?.backgroundColor = newValue
        }
    }

    public var color: UIColor = .white {
        didSet {
            loadViewIfNeeded()
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
        playPauseButton?.accessibilityLabel = NSLocalizedString("Play", bundle: .core, comment: "")
        currentTimeLabel?.accessibilityLabel = NSLocalizedString("Time elapsed", bundle: .core, comment: "")
        loadingView?.color = color
        remainingTimeLabel?.accessibilityLabel = NSLocalizedString("Total time", bundle: .core, comment: "")
        timeSlider?.accessibilityLabel = NSLocalizedString("Current position", bundle: .core, comment: "")
    }

    public func load(url: URL) {
        currentTimeLabel?.text = NSLocalizedString("--:--", bundle: .core, comment: "")
        remainingTimeLabel?.text = NSLocalizedString("--:--", bundle: .core, comment: "")
        loadingView?.startAnimating()
        playPauseButton?.alpha = 0
        playPauseButton?.isEnabled = false
        URLSessionAPI.cachingURLSession.dataTask(with: url) { [weak self] data, _, error in
            guard error == nil, let data = data else {
                DispatchQueue.main.async { self?.showError(error ?? NSError.internalError()) }
                return
            }
            DispatchQueue.main.async { self?.loadData(data) }
        }.resume()
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
                playPauseButton?.setImage(.icon(.pause, .solid), for: .normal)
                playPauseButton?.accessibilityLabel = NSLocalizedString("Pause", bundle: .core, comment: "")
                timer = CADisplayLink(target: self, selector: #selector(tick))
                timer?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            }
        } catch {
            showError(error)
        }
    }

    @objc func tick(_ timer: CADisplayLink? = nil) {
        guard let player = player else { return }
        currentTimeLabel?.text = formatter.string(from: player.currentTime)
        remainingTimeLabel?.text = formatter.string(from: player.duration)
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
        playPauseButton?.setImage(.icon(.play, .solid), for: .normal)
        playPauseButton?.accessibilityLabel = NSLocalizedString("Play", bundle: .core, comment: "")
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    @IBAction func playPause(_ sender: UIButton) {
        if player?.isPlaying == true {
            pause()
        } else {
            play()
        }
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
