//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit
import AVFoundation

private let recordingTopMargin: CGFloat = 46
private let playbackTopMargin: CGFloat = 28
private let recordingBottomMargin: CGFloat = -34
private let playbackBottomMargin: CGFloat = 0

private let meterTicks = 13

// this is an abstraction introduced for the purposes of testing
public protocol AudioRecorderPermissionDelegate {
    func requestRecordPermission(_ response: @escaping AVFoundation.PermissionBlock)
    var recordPermission: AVAudioSession.RecordPermission { get }
}

extension AVAudioSession: AudioRecorderPermissionDelegate {
}

open class AudioRecorderView: UIView {
    // MARK: State
    
    fileprivate var state: State = .preRecording(.undetermined)
    var permissionDelegate: AudioRecorderPermissionDelegate = AVAudioSession.sharedInstance() {
        didSet {
            setState(.preRecording(permissionDelegate.recordPermission), animated: false)
        }
    }
    
    fileprivate func setState(_ newState: State, animated: Bool) {
        state = newState
        state.transitionToState(self, animated: animated)
    }
    
    fileprivate enum State {
        case preRecording(AVAudioSession.RecordPermission)
        case recording(AudioRecorder)
        case playing(AudioPlayer)
        case paused(AudioPlayer)
        
        fileprivate func transitionToState(_ view: AudioRecorderView, animated: Bool) {
            var disabled = (trash: true, meter: false, done: false)
            
            switch self {
            case .preRecording(AVAudioSession.RecordPermission.denied):
                view.recordButton.recordButtonState = .denied(.denied)
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 0
                disabled.done = true
                
            case .preRecording(AVAudioSession.RecordPermission.undetermined):
                view.recordButton.recordButtonState = .denied(.undetermined)
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 0
                disabled.done = true
                
                
            case .recording:
                view.recordButton.recordButtonState = .stop
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 3
                disabled.done = true
                
            case .preRecording(_):
                view.recordButton.recordButtonState = .record
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 0
                disabled.done = true
                disabled.meter = true
                view.durationLabel.text = "00:00.0"
                
            case .playing(let player):
                view.recordButton.recordButtonState = .pause
                view.recordButtonTopConstraint.constant = playbackTopMargin
                view.playbackBottomConstraint.constant = playbackBottomMargin
                view.volumeMeterView.level = 12
                
                view.playbackScrubber.update(player.duration, currentTime: player.currentTime)
                
            case .paused(let player):
                view.recordButton.recordButtonState = .play
                view.recordButtonTopConstraint.constant = playbackTopMargin
                view.playbackBottomConstraint.constant = playbackBottomMargin
                disabled.trash = false
                disabled.meter = true
                view.volumeMeterView.level = 0
                
                view.playbackScrubber.update(player.duration, currentTime: player.currentTime)
            }
            
            let updateBlock: ()->() = {
                view.layoutIfNeeded()
                view.trashButton.alpha = disabled.trash ? 0.0: 1.0
                view.volumeMeterView.alpha = disabled.meter ? 0.0: 1.0
                view.doneButton.isEnabled = !disabled.done
            }
            
            if animated {
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: updateBlock, completion:nil)
            } else {
                updateBlock()
            }
        }
        
        fileprivate func recordButtonTapped(_ view: AudioRecorderView) {
            switch self {
            case .preRecording(AVAudioSession.RecordPermission.denied):
                let title = NSLocalizedString("Not Permitted", tableName: "Localizable", bundle: .core, value: "", comment: "can't record because request for mic access was denied title")
                
                let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Canvas"
                let message = NSLocalizedString("You must grant \(appName) Microphone access in the Settings app in order to record audio.", tableName: "Localizable", bundle: .core, value: "", comment: "permission was rejected")
                
                let error = NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                view.notifyUserOfError(error, title: title, dismissToState: .preRecording(.denied))
                
            case .preRecording(AVAudioSession.RecordPermission.undetermined):
                view.permissionDelegate.requestRecordPermission { permissionGranted in
                    if permissionGranted {
                        view.setState(.preRecording(.granted), animated: true)
                    } else {
                        print("Denied!")
                        view.setState(.preRecording(.denied), animated: true)
                    }
                }
                
            case .recording(let recorder):
                view.finishRecordingWithRecorder(recorder)
                
            case .preRecording(_):
                view.startRecording()
                
            case .paused(let player):
                player.play()
                view.setState(.playing(player), animated: true)
                
            case .playing(let player):
                player.pause()
                view.setState(.paused(player), animated: true)
            }
        }
        
        fileprivate func trashButtonTapped(_ view: AudioRecorderView) {
            switch self {
            case .paused(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL as URL) {
                    view.setState(.preRecording(view.permissionDelegate.recordPermission), animated: true)
                }
            case .playing(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL as URL) {
                    view.setState(.preRecording(view.permissionDelegate.recordPermission), animated: true)
                }
                
            default: break
            }
        }
        
        fileprivate func setPlaybackTime(_ time: TimeInterval) {
            switch self {
            case .paused(let player):
                player.currentTime = time
            case .playing(let player):
                player.currentTime = time
            default: break
            }
        }
        
        fileprivate func doneButtonTapped(_ view: AudioRecorderView) {
            switch self {
            case .paused(let player):
                view.didFinishRecordingAudioFile(player.audioFileURL as URL)
            case .playing(let player):
                view.didFinishRecordingAudioFile(player.audioFileURL as URL)
            default:
                break // Done button is disabled. This should never happen.
            }
        }
        
        fileprivate func cancelButtonTapped(_ view: AudioRecorderView) {
            switch self {
            case .paused(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL as URL, onConfirmation: view.didCancel)
            case .playing(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL as URL, onConfirmation: view.didCancel)
                recordButtonTapped(view) // pause the player
            case .recording(let recorder) where recorder.recordedFileURL != nil:
                view.confirmDeletionOfFileAtURL(recorder.recordedFileURL! as URL, onConfirmation: view.didCancel)
                recordButtonTapped(view) // stop recording 
            default:
                view.didCancel()
            }
        }
    }
    
    // MARK: life cycle
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        localizeButtons()
        state.transitionToState(self, animated: false)
    }
    
    @objc func localizeButtons() {
        cancelButton.setTitle(NSLocalizedString("Cancel", tableName: "Localizable", bundle: .core, value: "", comment: "Cancel Audio recording."), for: .normal)
    }
    
    // MARK: callbacks

    @objc open var didCancel: ()->() = {}
    @objc open var presentAlert: (UIAlertController)->() = { _ in }
    @objc open var didFinishRecordingAudioFile: (URL)->() = { _ in }
    @objc open var completeButtonTitle: String {
        set {
            self.doneButton.setTitle(newValue, for: UIControl.State())
            self.doneButton.accessibilityLabel = newValue
            self.doneButton.accessibilityIdentifier = newValue
        } get {
            return self.doneButton.title(for: UIControl.State()) ?? ""
        }
    }
    

    
    // MARK: UI Outlets
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var recordButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var playbackBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var volumeMeterView: VolumeLevelMeterView!
    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var trashButton: UIButton!
    
    @IBOutlet weak var playbackScrubber: PlaybackScrubber!
    
    
    // MARK: UI Actions
    
    @IBAction func recordButtonTapped(_ sender: AnyObject) {
        state.recordButtonTapped(self)
    }
    
    @IBAction func trashButtonTapped(_ sender: AnyObject) {
        state.trashButtonTapped(self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        state.cancelButtonTapped(self)
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        state.doneButtonTapped(self)
    }
}

// MARK: Error handling

extension AudioRecorderView {

    fileprivate func notifyUserOfError(_ error: NSError, title: String, dismissToState: AudioRecorderView.State = .preRecording(.granted)) {
        let errorController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let dismiss = NSLocalizedString("Dismiss", tableName: "Localizable", bundle: .core, value: "", comment: "Dismiss an error dialog")
        errorController.addAction(UIAlertAction(title: dismiss, style: .default) { _ in
            self.setState(dismissToState, animated: true)
        })
        
        presentAlert(errorController)
    }
}


// MARK: Audio Recording

private let recordingErrorTitle = NSLocalizedString("Recording Error", tableName: "Localizable", bundle: .core, value: "", comment: "title for a recording error")

extension AudioRecorderView: AudioRecorderDelegate {
    @objc func startRecording() {
        let recorder = AudioRecorder(ticks: meterTicks)
        recorder.delegate = self
        
        do {
            try recorder.startRecording()
            
            setState(.recording(recorder), animated: true)
        } catch let error as NSError {
            notifyUserOfError(error, title: recordingErrorTitle)
        }
    }
    
    @objc func finishRecordingWithRecorder(_ recorder: AudioRecorder) {
        recorder.stopRecording()

        do {
            if let fileURL = recorder.recordedFileURL {
                let player = try AudioPlayer(audioFileURL: fileURL, ticks:meterTicks)
                player.delegate = self
                setState(.paused(player), animated: true)
            } else {
                let error = NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The file does not exist.", tableName: "Localizable", bundle: .core, value: "", comment: "Error message for a file missing")])
                notifyUserOfError(error, title: recordingErrorTitle)
            }
        } catch let error as NSError {
            notifyUserOfError(error, title: recordingErrorTitle)
        }
    }
    
    @objc func recorder(_ recorder: AudioRecorder, didFinishRecordingWithError error: NSError?) {
        if let error = error {
            notifyUserOfError(error, title: recordingErrorTitle)
        } else {
            finishRecordingWithRecorder(recorder)
        }
    }
    
    @objc func recorder(_ recorder: AudioRecorder, progressWithTime time: TimeInterval, meter: Int) {
        volumeMeterView.level = meter
        durationLabel.text = time.formatted(true)
    }
}


// MARK: Audio Playback

extension AudioRecorderView: AudioPlayerDelegate {
    @objc func player(_ player: AudioPlayer, finishedWithError error: NSError?) {
        if let error = error {
            notifyUserOfError(error, title: NSLocalizedString("Playback Error", tableName: "Localizable", bundle: .core, value: "", comment: "Title for playback error messages"), dismissToState: .paused(player))
        } else {
            setState(.paused(player), animated: true)
        }
    }
    
    @objc func player(_ player: AudioPlayer, progressUpdatedWithCurrentTime currentTime: TimeInterval, meter: Int) {
        
        playbackScrubber.update(player.duration, currentTime: player.currentTime)
        
        volumeMeterView.level = meter
    }
    
    
    @IBAction func scrub(_ sender: AnyObject) {
        state.setPlaybackTime(playbackScrubber.currentTime)
    }
}


// MARK: file management

extension AudioRecorderView {
    @objc func confirmDeletionOfFileAtURL(_ url: URL, onConfirmation: @escaping ()->()) {
        let message = NSLocalizedString("Delete recording?", tableName: "Localizable", bundle: .core, value: "", comment: "message for delete dialog of audio recorder")
        let controller = UIAlertController(title: message, message: nil, preferredStyle: .actionSheet)
        
        let delete = NSLocalizedString("Delete", tableName: "Localizable", bundle: .core, value: "", comment: "Delete button")
        controller.addAction(UIAlertAction(title: delete, style: .destructive) { _ in
            do { try FileManager.default.removeItem(at: url) } catch { }
            onConfirmation()
        })
        
        let cancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: .core, value: "", comment: "Cancel button title")
        controller.addAction(UIAlertAction(title: cancel, style: .cancel) { _ in
            // do nothing!
        })
        
        controller.popoverPresentationController?.sourceView = trashButton
        controller.popoverPresentationController?.sourceRect = trashButton.bounds
        
        presentAlert(controller)
    }
}
