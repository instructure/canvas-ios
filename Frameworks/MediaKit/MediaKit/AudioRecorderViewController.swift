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
import SoPretty
import AVFoundation

open class AudioRecorderViewController: UIViewController {
    
    open static func presentFromViewController(_ viewController: UIViewController, completeButtonTitle: String) -> AudioRecorderViewController {
        return presentFromViewController(viewController, completeButtonTitle: completeButtonTitle, permissionDelegate: AVAudioSession.sharedInstance())
    }
    
    open static func presentFromViewController(_ viewController: UIViewController, completeButtonTitle: String, permissionDelegate: AudioRecorderPermissionDelegate) -> AudioRecorderViewController {
        let bundle = Bundle(for: self)
        
        let nav = UIStoryboard(name: "AudioRecorderViewController", bundle: bundle).instantiateInitialViewController() as! SmallModalNavigationController
        let me = nav.viewControllers.first as! AudioRecorderViewController
        nav.preferredContentSize = CGSize(width: 300, height: 134)
        
        viewController.present(nav, animated: true, completion: nil)
        
        me.audioRecorderView.presentAlert = { [weak me] alert in
            me?.present(alert, animated: true, completion: nil)
        }
        me.audioRecorderView.permissionDelegate = permissionDelegate
        me.audioRecorderView.completeButtonTitle = completeButtonTitle
        return me
    }
    
    var audioRecorderView: AudioRecorderView {
        return view as! AudioRecorderView
    }
    
    open var cancelButtonTapped: ()->() {
        set {
            audioRecorderView.didCancel = newValue
        } get {
            return audioRecorderView.didCancel
        }
    }
    
    open var didFinishRecordingAudioFile: (URL)->() {
        set {
            audioRecorderView.didFinishRecordingAudioFile = newValue
        } get {
            return audioRecorderView.didFinishRecordingAudioFile
        }
    }
}
