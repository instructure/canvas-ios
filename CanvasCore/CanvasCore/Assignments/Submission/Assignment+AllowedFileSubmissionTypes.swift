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
import ReactiveCocoa
import Result



import CoreData


extension Assignment {
    public var allowedSubmissionUTIs: [String] {
        return Assignment.allowedSubmissionUTIs(submissionTypes, allowedExtensions: allowedExtensions)
    }

    public static func allowedSubmissionUTIs(_ submissionTypes: SubmissionTypes, allowedExtensions: [String]?) -> [String] {
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
}
