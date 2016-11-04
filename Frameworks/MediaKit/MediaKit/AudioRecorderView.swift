
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
    func requestRecordPermission(response: PermissionBlock)
    func recordPermission() -> AVAudioSessionRecordPermission
}

extension AVAudioSession: AudioRecorderPermissionDelegate {
}

public class AudioRecorderView: UIView {
    // MARK: State
    
    private var state: State = .PreRecording(.Undetermined)
    var permissionDelegate: AudioRecorderPermissionDelegate = AVAudioSession.sharedInstance() {
        didSet {
            setState(.PreRecording(permissionDelegate.recordPermission()), animated: false)
        }
    }
    
    private func setState(newState: State, animated: Bool) {
        state = newState
        state.transitionToState(self, animated: animated)
    }
    
    private enum State {
        case PreRecording(AVAudioSessionRecordPermission)
        case Recording(AudioRecorder)
        case Playing(AudioPlayer)
        case Paused(AudioPlayer)
        
        private func transitionToState(view: AudioRecorderView, animated: Bool) {
            var disabled = (trash: true, meter: false, done: false)
            
            switch self {
            case .PreRecording(AVAudioSessionRecordPermission.Denied):
                view.recordButton.recordButtonState = .Denied(.Denied)
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 0
                disabled.done = true
                
            case .PreRecording(AVAudioSessionRecordPermission.Undetermined):
                view.recordButton.recordButtonState = .Denied(.Undetermined)
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 0
                disabled.done = true
                
                
            case .Recording:
                view.recordButton.recordButtonState = .Stop
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 3
                disabled.done = true
                
            case .PreRecording(_):
                view.recordButton.recordButtonState = .Record
                view.recordButtonTopConstraint.constant = recordingTopMargin
                view.playbackBottomConstraint.constant = recordingBottomMargin
                view.volumeMeterView.level = 0
                disabled.done = true
                disabled.meter = true
                view.durationLabel.text = "00:00.0"
                
            case .Playing(let player):
                view.recordButton.recordButtonState = .Pause
                view.recordButtonTopConstraint.constant = playbackTopMargin
                view.playbackBottomConstraint.constant = playbackBottomMargin
                view.volumeMeterView.level = 12
                
                view.playbackScrubber.update(player.duration, currentTime: player.currentTime)
                
            case .Paused(let player):
                view.recordButton.recordButtonState = .Play
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
                view.doneButton.enabled = !disabled.done
            }
            
            if animated {
                UIView.animateWithDuration(0.15, delay: 0.0, options: .CurveEaseOut, animations: updateBlock, completion:nil)
            } else {
                updateBlock()
            }
        }
        
        private func recordButtonTapped(view: AudioRecorderView) {
            switch self {
            case .PreRecording(AVAudioSessionRecordPermission.Denied):
                let title = NSLocalizedString("Not Permitted", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "can't record because request for mic access was denied title")
                
                let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as? String ?? "Canvas"
                let message = NSLocalizedString("You must grant \(appName) Microphone access in the Settings app in order to record audio.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "permission was rejected")
                
                let error = NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                view.notifyUserOfError(error, title: title, dismissToState: .PreRecording(.Denied))
                
            case .PreRecording(AVAudioSessionRecordPermission.Undetermined):
                view.permissionDelegate.requestRecordPermission { permissionGranted in
                    if permissionGranted {
                        view.setState(.PreRecording(.Granted), animated: true)
                    } else {
                        print("Denied!")
                        view.setState(.PreRecording(.Denied), animated: true)
                    }
                }
                
            case .Recording(let recorder):
                view.finishRecordingWithRecorder(recorder)
                
            case .PreRecording(_):
                view.startRecording()
                
            case .Paused(let player):
                player.play()
                view.setState(.Playing(player), animated: true)
                
            case .Playing(let player):
                player.pause()
                view.setState(.Paused(player), animated: true)
            }
        }
        
        private func trashButtonTapped(view: AudioRecorderView) {
            switch self {
            case .Paused(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL) {
                    view.setState(.PreRecording(view.permissionDelegate.recordPermission()), animated: true)
                }
            case .Playing(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL) {
                    view.setState(.PreRecording(view.permissionDelegate.recordPermission()), animated: true)
                }
                
            default: break
            }
        }
        
        private func setPlaybackTime(time: NSTimeInterval) {
            switch self {
            case .Paused(let player):
                player.currentTime = time
            case .Playing(let player):
                player.currentTime = time
            default: break
            }
        }
        
        private func doneButtonTapped(view: AudioRecorderView) {
            switch self {
            case .Paused(let player):
                view.didFinishRecordingAudioFile(player.audioFileURL)
            case .Playing(let player):
                view.didFinishRecordingAudioFile(player.audioFileURL)
            default:
                break // Done button is disabled. This should never happen.
            }
        }
        
        private func cancelButtonTapped(view: AudioRecorderView) {
            switch self {
            case .Paused(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL, onConfirmation: view.didCancel)
            case .Playing(let player):
                view.confirmDeletionOfFileAtURL(player.audioFileURL, onConfirmation: view.didCancel)
                recordButtonTapped(view) // pause the player
            case .Recording(let recorder) where recorder.recordedFileURL != nil:
                view.confirmDeletionOfFileAtURL(recorder.recordedFileURL!, onConfirmation: view.didCancel)
                recordButtonTapped(view) // stop recording 
            default:
                view.didCancel()
            }
        }
    }
    
    // MARK: life cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        state.transitionToState(self, animated: false)
    }
    
    // MARK: callbacks

    public var didCancel: ()->() = {}
    public var presentAlert: UIAlertController->() = { _ in }
    public var didFinishRecordingAudioFile: NSURL->() = { _ in }
    public var completeButtonTitle: String {
        set {
            self.doneButton.setTitle(newValue, forState: .Normal)
            self.doneButton.accessibilityLabel = newValue
            self.doneButton.accessibilityIdentifier = newValue
        } get {
            return self.doneButton.titleForState(.Normal) ?? ""
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
    
    @IBAction func recordButtonTapped(sender: AnyObject) {
        state.recordButtonTapped(self)
    }
    
    @IBAction func trashButtonTapped(sender: AnyObject) {
        state.trashButtonTapped(self)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        state.cancelButtonTapped(self)
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        state.doneButtonTapped(self)
    }
}

// MARK: Error handling

extension AudioRecorderView {

    private func notifyUserOfError(error: NSError, title: String, dismissToState: AudioRecorderView.State = .PreRecording(.Granted)) {
        let errorController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .Alert)
        let dismiss = NSLocalizedString("Dismiss", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Dismiss an error dialog")
        errorController.addAction(UIAlertAction(title: dismiss, style: .Default) { _ in
            self.setState(dismissToState, animated: true)
        })
        
        presentAlert(errorController)
    }
}


// MARK: Audio Recording

private let recordingErrorTitle = NSLocalizedString("Recording Error", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "title for a recording error")

extension AudioRecorderView: AudioRecorderDelegate {
    func startRecording() {
        let recorder = AudioRecorder(ticks: meterTicks)
        recorder.delegate = self
        
        do {
            try recorder.startRecording()
            
            setState(.Recording(recorder), animated: true)
        } catch let error as NSError {
            notifyUserOfError(error, title: recordingErrorTitle)
        }
    }
    
    func finishRecordingWithRecorder(recorder: AudioRecorder) {
        recorder.stopRecording()

        do {
            if let fileURL = recorder.recordedFileURL {
                let player = try AudioPlayer(audioFileURL: fileURL, ticks:meterTicks)
                player.delegate = self
                setState(.Paused(player), animated: true)
            } else {
                let error = NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The file does not exist.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Error message for a file missing")])
                notifyUserOfError(error, title: recordingErrorTitle)
            }
        } catch let error as NSError {
            notifyUserOfError(error, title: recordingErrorTitle)
        }
    }
    
    func recorder(recorder: AudioRecorder, didFinishRecordingWithError error: NSError?) {
        if let error = error {
            notifyUserOfError(error, title: recordingErrorTitle)
        } else {
            finishRecordingWithRecorder(recorder)
        }
    }
    
    func recorder(recorder: AudioRecorder, progressWithTime time: NSTimeInterval, meter: Int) {
        volumeMeterView.level = meter
        durationLabel.text = time.formatted(true)
    }
}


// MARK: Audio Playback

extension AudioRecorderView: AudioPlayerDelegate {
    func player(player: AudioPlayer, finishedWithError error: NSError?) {
        if let error = error {
            notifyUserOfError(error, title: NSLocalizedString("Playback Error", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Title for playback error messages"), dismissToState: .Paused(player))
        } else {
            setState(.Paused(player), animated: true)
        }
    }
    
    func player(player: AudioPlayer, progressUpdatedWithCurrentTime currentTime: NSTimeInterval, meter: Int) {
        
        playbackScrubber.update(player.duration, currentTime: player.currentTime)
        
        volumeMeterView.level = meter
    }
    
    
    @IBAction func scrub(sender: AnyObject) {
        state.setPlaybackTime(playbackScrubber.currentTime)
    }
}


// MARK: file management

extension AudioRecorderView {
    func confirmDeletionOfFileAtURL(url: NSURL, onConfirmation: ()->()) {
        let message = NSLocalizedString("Delete recording?", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "message for delete dialog of audio recorder")
        let controller = UIAlertController(title: message, message: nil, preferredStyle: .ActionSheet)
        
        let delete = NSLocalizedString("Delete", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Delete button")
        controller.addAction(UIAlertAction(title: delete, style: .Destructive) { _ in
            do { try NSFileManager.defaultManager().removeItemAtURL(url) } catch { }
            onConfirmation()
        })
        
        let cancel = NSLocalizedString("Cancel", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.MediaKit")!, value: "", comment: "Cancel button title")
        controller.addAction(UIAlertAction(title: cancel, style: .Cancel) { _ in
            // do nothing!
        })
        
        if let popover = controller.popoverPresentationController {
            popover.sourceView = trashButton
        }
        
        presentAlert(controller)
    }
}
