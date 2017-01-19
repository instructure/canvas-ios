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
    
    

import Foundation

import MobileCoreServices


extension Assignment {
    // these are the allowed file types
    public var allowedSubmissionUTIs: [String] {
        var utis: [String] = []
        
        var startDotStar = false
        
        if submissionTypes.contains(.upload) {
            if let count = allowedExtensions?.count, count > 0 {
                utis += (allowedExtensions ?? []).map(toUTI)
            } else {
                startDotStar = true
                utis = [kUTTypeItem as String]
            }
        }
        
        if !startDotStar && submissionTypes.contains(.mediaRecording) {
            utis += [kUTTypeMovie as String, kUTTypeAudio as String]
        }

        if submissionTypes.contains(.text) {
            utis += [kUTTypeText as String]
        }

        if submissionTypes.contains(.url) {
            utis += [kUTTypeURL as String]
        }

        return utis
    }

    public var allowsAllFiles: Bool {
        return allowedSubmissionUTIs.contains(kUTTypeItem as String)
    }
    
    public var allowsPhotos: Bool {
        return allowsAllFiles || allowedSubmissionUTIs.filter(isUTIPhoto).count > 0
    }
    
    public var allowsVideo: Bool {
        return allowsAllFiles || allowedSubmissionUTIs.filter(isUTIVideo).count > 0
    }
    
    public var allowsAudio: Bool {
        return allowsAllFiles || allowedSubmissionUTIs.filter(isUTIAudio).count > 0
    }
    
    public var allowedImagePickerControllerMediaTypes: [String] {
        let images =  allowsPhotos ? [kUTTypeImage as String] : []
        let video = allowsVideo ? [kUTTypeMovie as String] : []
        
        return images + video
    }
}


private func toUTI(_ ext: String) -> String {
    let cfUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
        .map { $0.takeRetainedValue() }
        .map { $0 as String }
    
    return cfUTI ?? ""
}

private func isUTIVideo(_ uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeMovie)
}

private func isUTIPhoto(_ uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeImage)
}

private func isUTIAudio(_ uti: String) -> Bool {
    return UTTypeConformsTo(uti as CFString, kUTTypeAudio)
}
