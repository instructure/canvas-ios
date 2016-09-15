//
//  TextSubmissionAction.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/2/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

class TextSubmissionAction: UploadAction {
    let title = NSLocalizedString("Text", comment: "Text submission option")
    let icon = UIImage.FileKitImageNamed("icon_text")
    let currentSubmission: NewUpload
    weak var delegate: UploadActionDelegate?
    
    init(currentSubmission: NewUpload, delegate: UploadActionDelegate) {
        self.currentSubmission = currentSubmission
        self.delegate = delegate
    }
    
    func initiate() {
        switch currentSubmission {
        case .Text(_):
            delegate?.chooseUpload(currentSubmission)
        default:
            delegate?.chooseUpload(.Text(""))
        }
    }
}
