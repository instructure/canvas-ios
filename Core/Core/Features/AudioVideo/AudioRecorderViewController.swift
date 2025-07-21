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
import UIKit

public protocol AudioRecorderDelegate: AnyObject {
    func cancel(_ controller: AudioRecorderViewController)
    func send(_ controller: AudioRecorderViewController, url: URL)
}

public class AudioRecorderViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var borderView: UIView?
    @IBOutlet weak var cancelButton: DynamicButton?
    @IBOutlet weak var clearButton: DynamicButton?
    @IBOutlet weak var playerView: UIView?
    @IBOutlet weak var recordButton: DynamicButton?
    @IBOutlet weak var sendButton: DynamicButton?
    @IBOutlet weak var stopButton: DynamicButton?
    @IBOutlet weak var timeLabel: DynamicLabel?

    public weak var delegate: AudioRecorderDelegate?
    lazy var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    let player = AudioPlayerViewController.create()
    var recorder: AVAudioRecorder?
    var timer: CADisplayLink?
    public lazy var url = URL.Directories.temporary.appendingPathComponent("\(UUID.string).m4a")

    public static func create() -> AudioRecorderViewController {
        let controller = loadFromStoryboard()
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        borderView?.layer.borderColor = UIColor.borderMedium.cgColor
        cancelButton?.accessibilityLabel = String(localized: "Cancel", bundle: .core)
        clearButton?.accessibilityLabel = String(localized: "Clear recording", bundle: .core)
        player.accessibilityPrefix = "AudioRecorder."
        if let view = playerView { embed(player, in: view) }
        recordButton?.accessibilityLabel = String(localized: "Start recording", bundle: .core)
        sendButton?.setTitle(String(localized: "Send", bundle: .core), for: .normal)
        stopButton?.accessibilityLabel = String(localized: "Stop recording", bundle: .core)
    }

    @IBAction func record(_ sender: UIButton) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
            recorder = try AVAudioRecorder(url: url, settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 22050,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ])
            recorder?.delegate = self
            if recorder?.record() == true {
                timer = CADisplayLink(target: self, selector: #selector(tick))
                timer?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
                clearButton?.isHidden = true
                recordButton?.isHidden = true
                stopButton?.isHidden = false
            } else {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            showError(error)
        }
    }

    @objc func tick(_ timer: CADisplayLink) {
        guard let recorder = recorder, recorder.isRecording else { return }
        timeLabel?.text = formatter.string(from: recorder.currentTime)
    }

    @IBAction func stop(_ sender: UIButton? = nil) {
        timer?.invalidate()
        timer = nil
        recorder?.delegate = nil
        recorder?.stop()
        recorder = nil
        borderView?.isHidden = true
        clearButton?.isHidden = false
        player.load(url: url)
        playerView?.isHidden = false
        recordButton?.isHidden = true
        sendButton?.isHidden = false
        stopButton?.isHidden = true
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            showError(error)
        }
    }

    @IBAction func clear(_ sender: UIButton) {
        try? FileManager.default.removeItem(at: url)
        borderView?.isHidden = false
        clearButton?.isHidden = true
        player.pause()
        player.load(url: nil)
        playerView?.isHidden = true
        recordButton?.isHidden = false
        sendButton?.isHidden = true
        stopButton?.isHidden = true
        timeLabel?.text = formatter.string(from: 0)
    }

    @IBAction func send(_ sender: UIButton) {
        delegate?.send(self, url: url)
    }

    @IBAction func cancel(_ sender: UIButton) {
        clear(sender)
        recorder?.stop()
        delegate?.cancel(self)
    }
}

extension AudioRecorderViewController: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stop()
    }

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        stop()
        if let error = error { showError(error) }
    }
}
