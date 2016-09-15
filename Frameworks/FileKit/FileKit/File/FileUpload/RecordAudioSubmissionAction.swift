//
//  RecordAudioSubmissionAction.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/2/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit
import MediaKit

class RecordAudioSubmissionAction: UploadAction {
    let title: String = NSLocalizedString("Record Audio", comment: "Choose record audio submission")
    let icon: UIImage = .FileKitImageNamed("icon_audio")
    
    weak var viewController: UIViewController?
    weak var delegate: UploadActionDelegate?
    
    init(viewController: UIViewController?, delegate: UploadActionDelegate) {
        self.viewController = viewController
        self.delegate = delegate
    }

    func initiate() {
        guard let vc = viewController else { return print("There was no view controller, it must have died") }
        let recorder = AudioRecorderViewController.presentFromViewController(vc, completeButtonTitle: NSLocalizedString("Turn In", comment: "Turn in button title"))
        
        recorder.cancelButtonTapped = { [weak delegate, weak vc] in
            vc?.dismissViewControllerAnimated(true) {
                delegate?.actionCancelled()
            }
        }
        
        recorder.didFinishRecordingAudioFile = { [weak delegate, weak vc] url in
            
            vc?.dismissViewControllerAnimated(true) {
                delegate?.chooseUpload(.MediaComment(.AudioFile(url)))
            }
        }
    }
}