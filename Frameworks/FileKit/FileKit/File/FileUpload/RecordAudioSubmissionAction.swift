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
import MediaKit
import ReactiveSwift
import Result

class RecordAudioSubmissionAction: FileUploadAction {
    weak var delegate: FileUploadActionDelegate?
    let title: String = NSLocalizedString("Record Audio", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Choose record audio submission")
    let icon: UIImage = .FileKitImageNamed("icon_audio")

    func initiate() {
        let recorder = AudioRecorderViewController.new(completeButtonTitle: NSLocalizedString("Turn In", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Turn in button title"))
        delegate?.fileUploadAction(self, wantsToPresent: recorder)
        
        recorder.cancelButtonTapped = { [weak self] in
            guard let me = self else { return }
            recorder.dismiss(animated: true) {
                me.delegate?.fileUploadActionDidCancel(me)
            }
        }
        
        recorder.didFinishRecordingAudioFile = { [weak self] url in
            guard let me = self else { return }
            guard let data = try? Data(contentsOf: url) else {
                recorder.dismiss(animated: true) {
                    me.delegate?.fileUploadActionFailedToConvertData(me)
                }
                return
            }
            recorder.dismiss(animated: true) {
                me.delegate?.fileUploadAction(me, finishedWith: NewFileUpload(kind: .audioFile(url), data: data))
            }
        }
    }
}
