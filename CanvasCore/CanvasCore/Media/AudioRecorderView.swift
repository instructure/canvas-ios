//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    func recordPermission() -> AVAudioSessionRecordPermission
}

extension AVAudioSession: AudioRecorderPermissionDelegate {
}

open class AudioRecorderView: UIView {
    // MARK: State
    
    fileprivate var state: State = .preRecording(.undetermined)
    var permissionDelegate: AudioRecorderPermissionDelegate = AVAudioSession.sharedInstance() {
        didSet {
            setState(.preRecording(permissionDelegate.recordPermission()), animated: false)
        }
    }
    
    fileprivate func setState(_ newState: State, animated: Bool) {
        state = newState
        state.transitionToState(self, animated: animated)
    }
    
    fileprivate enum State {
        case preRecording(AVAudioSessionRecordPermission)
        case recording(AudioRecorder)
        case playing(AudioPlayer)
        case paused(AudioPlayer)
        
        fileprivate func transitionToState(_ view: AudioRecorderView, animated: Bool) {
            var disabled = (trash: true, meter: false, done: false)
            
            switch self {
            case .preRecording(AVAudioSessionRecordPermission.denied):
                view.recordButton.recordButtonState = .denied(.denied)
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 0
                disabled.done = true
                
            case .preRecording(AVAudioSessionRecordPermission.undetermined):
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
            case .preRecording(AVAudioSessionRecordPermission.denied):
                let title = NSLocalizedString("Not Permitted", tableName: "Localizable", bundle: .core, value: "", comment: "can't record because request for mic access was denied title")
                
                let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Canvas"
                let message = NSLocalizedString("You must grant \(appName) Microphone access in the Settings app in order to record audio.", tableName: "Localizable", bundle: .core, value: "", comment: "permission was rejected")
                
                let error = NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                view.notifyUserOfError(error, title: title, dismissToState: .preRecording(.denied))
                
            case .preRecording(AVAudioSessionRecordPermission.undetermined):
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
                    view.setState(.preRecording(view.permissionDelegate.recordPermission()), animated: true)
                }
            case .playing(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL as URL) {
                    view.setState(.preRecording(view.permissionDelegate.recordPermission()), animated: true)
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
    
    func localizeButtons() {
        cancelButton.setTitle(NSLocalizedString("Cancel", tableName: "Localizable", bundle: .core, value: "", comment: "Cancel Audio recording."), for: .normal)
    }
    
    // MARK: callbacks

    open var didCancel: ()->() = {}
    open var presentAlert: (UIAlertController)->() = { _ in }
    open var didFinishRecordingAudioFile: (URL)->() = { _ in }
    open var completeButtonTitle: String {
        set {
            self.doneButton.setTitle(newValue, for: UIControlState())
            self.doneButton.accessibilityLabel = newValue
            self.doneButton.accessibilityIdentifier = newValue
        } get {
            return self.doneButton.title(for: UIControlState()) ?? ""
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
    func startRecording() {
        let recorder = AudioRecorder(ticks: meterTicks)
        recorder.delegate = self
        
        do {
            try recorder.startRecording()
            
            setState(.recording(recorder), animated: true)
        } catch let error as NSError {
            notifyUserOfError(error, title: recordingErrorTitle)
        }
    }
    
    func finishRecordingWithRecorder(_ recorder: AudioRecorder) {
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
    
    func recorder(_ recorder: AudioRecorder, didFinishRecordingWithError error: NSError?) {
        if let error = error {
            notifyUserOfError(error, title: recordingErrorTitle)
        } else {
            finishRecordingWithRecorder(recorder)
        }
    }
    
    func recorder(_ recorder: AudioRecorder, progressWithTime time: TimeInterval, meter: Int) {
        volumeMeterView.level = meter
        durationLabel.text = time.formatted(true)
    }
}


// MARK: Audio Playback

extension AudioRecorderView: AudioPlayerDelegate {
    func player(_ player: AudioPlayer, finishedWithError error: NSError?) {
        if let error = error {
            notifyUserOfError(error, title: NSLocalizedString("Playback Error", tableName: "Localizable", bundle: .core, value: "", comment: "Title for playback error messages"), dismissToState: .paused(player))
        } else {
            setState(.paused(player), animated: true)
        }
    }
    
    func player(_ player: AudioPlayer, progressUpdatedWithCurrentTime currentTime: TimeInterval, meter: Int) {
        
        playbackScrubber.update(player.duration, currentTime: player.currentTime)
        
        volumeMeterView.level = meter
    }
    
    
    @IBAction func scrub(_ sender: AnyObject) {
        state.setPlaybackTime(playbackScrubber.currentTime)
    }
}


// MARK: file management

extension AudioRecorderView {
    func confirmDeletionOfFileAtURL(_ url: URL, onConfirmation: @escaping ()->()) {
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
        
        if let popover = controller.popoverPresentationController {
            popover.sourceView = trashButton
        }
        
        presentAlert(controller)
    }
}
