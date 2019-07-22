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

import Foundation
import MobileCoreServices
import ReactiveCocoa
import CoreData

extension Assignment {
    @objc public var allowedSubmissionUTIs: [String] {
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
