//
//  AudioRecorderViewController.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 9/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import SoPretty
import AVFoundation

public class AudioRecorderViewController: UIViewController {
    
    public static func presentFromViewController(viewController: UIViewController, completeButtonTitle: String) -> AudioRecorderViewController {
        return presentFromViewController(viewController, completeButtonTitle: completeButtonTitle, permissionDelegate: AVAudioSession.sharedInstance())
    }
    
    public static func presentFromViewController(viewController: UIViewController, completeButtonTitle: String, permissionDelegate: AudioRecorderPermissionDelegate) -> AudioRecorderViewController {
        let bundle = NSBundle(forClass: self)
        
        let nav = UIStoryboard(name: "AudioRecorderViewController", bundle: bundle).instantiateInitialViewController() as! SmallModalNavigationController
        let me = nav.viewControllers.first as! AudioRecorderViewController
        nav.preferredContentSize = CGSize(width: 300, height: 134)
        
        viewController.presentViewController(nav, animated: true, completion: nil)
        
        me.audioRecorderView.presentAlert = { [weak me] alert in
            me?.presentViewController(alert, animated: true, completion: nil)
        }
        me.audioRecorderView.permissionDelegate = permissionDelegate
        me.audioRecorderView.completeButtonTitle = completeButtonTitle
        return me
    }
    
    var audioRecorderView: AudioRecorderView {
        return view as! AudioRecorderView
    }
    
    public var cancelButtonTapped: ()->() {
        set {
            audioRecorderView.didCancel = newValue
        } get {
            return audioRecorderView.didCancel
        }
    }
    
    public var didFinishRecordingAudioFile: NSURL->() {
        set {
            audioRecorderView.didFinishRecordingAudioFile = newValue
        } get {
            return audioRecorderView.didFinishRecordingAudioFile
        }
    }
}
