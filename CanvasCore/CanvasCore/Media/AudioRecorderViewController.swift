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

public class AudioRecorderViewController: SmallModalNavigationController {
    @objc public static func present(from viewController: UIViewController, completeButtonTitle: String) -> AudioRecorderViewController {
        return present(from: viewController, completeButtonTitle: completeButtonTitle, permissionDelegate: AVAudioSession.sharedInstance())
    }

    public static func present(from viewController: UIViewController, completeButtonTitle: String, permissionDelegate: AudioRecorderPermissionDelegate) -> AudioRecorderViewController {
        let me = new(completeButtonTitle: completeButtonTitle, permissionDelegate: permissionDelegate)
        viewController.present(me, animated: true, completion: nil)
        return me
    }

    public static func new(completeButtonTitle: String, permissionDelegate: AudioRecorderPermissionDelegate = AVAudioSession.sharedInstance()) -> AudioRecorderViewController {
        let bundle = Bundle(for: self)

        let me = UIStoryboard(name: "AudioRecorderViewController", bundle: bundle).instantiateInitialViewController() as! AudioRecorderViewController
        me.preferredContentSize = CGSize(width: 300, height: 134)
        
        me.audioRecorderView.presentAlert = { [weak me] alert in
            me?.present(alert, animated: true, completion: nil)
        }
        me.audioRecorderView.permissionDelegate = permissionDelegate
        me.audioRecorderView.completeButtonTitle = completeButtonTitle
        return me
    }

    @objc var audioRecorderView: AudioRecorderView {
        return viewControllers.first!.view as! AudioRecorderView
    }
    
    @objc public var cancelButtonTapped: ()->() {
        set {
            audioRecorderView.didCancel = newValue
        } get {
            return audioRecorderView.didCancel
        }
    }
    
    @objc public var didFinishRecordingAudioFile: (URL)->() {
        set {
            audioRecorderView.didFinishRecordingAudioFile = newValue
        } get {
            return audioRecorderView.didFinishRecordingAudioFile
        }
    }
}
