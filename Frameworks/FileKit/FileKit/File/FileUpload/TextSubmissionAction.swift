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

class TextSubmissionAction: UploadAction {
    let title = NSLocalizedString("Text", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Text submission option")
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
