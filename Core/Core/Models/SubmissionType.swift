//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public enum SubmissionType: String, Codable {
    case discussion_topic
    case external_tool
    case media_recording
    case none
    case not_graded
    case online_quiz
    case online_text_entry
    case online_upload
    case online_url
    case on_paper
    case basic_lti_launch

    public var localizedString: String {
        switch self {
        case .discussion_topic:
            return NSLocalizedString("Discussion Comment", bundle: .core, comment: "")
        case .external_tool, .basic_lti_launch:
            return NSLocalizedString("External Tool", bundle: .core, comment: "")
        case .media_recording:
            return NSLocalizedString("Media Recording", bundle: .core, comment: "")
        case .none:
            return NSLocalizedString("No Submission", bundle: .core, comment: "")
        case .not_graded:
            return NSLocalizedString("Not Graded", bundle: .core, comment: "")
        case .online_quiz:
            return NSLocalizedString("Quiz", bundle: .core, comment: "")
        case .online_text_entry:
            return NSLocalizedString("Text Entry", bundle: .core, comment: "")
        case .online_upload:
            return NSLocalizedString("File Upload", bundle: .core, comment: "")
        case .online_url:
            return NSLocalizedString("Website URL", bundle: .core, comment: "")
        case .on_paper:
            return NSLocalizedString("On Paper", bundle: .core, comment: "")
        }
    }
}

extension Array where Element == SubmissionType {
    var isOnline: Bool {
        if contains(.on_paper) || contains(.not_graded) || contains(.none) {
            return false
        }
        return true
    }

    public var allowedMediaTypes: [String] {
        var types  = [kUTTypeMovie as String]

        if contains(.media_recording) && !contains(.online_upload) {
            types.append(kUTTypeAudio as String)
        } else {
            types.append(kUTTypeImage as String)
        }
        return types
    }

    public func allowedUTIs(allowedExtensions: [String] = [])  -> [UTI] {
        var utis: [UTI] = []

        if contains(.online_upload) {
            if allowedExtensions.isEmpty {
                utis += [.any]
            } else {
                utis += allowedExtensions.compactMap(UTI.init)
            }
        }

        if contains(.media_recording) {
            utis += [.video, .audio]
        }

        if contains(.online_text_entry) {
            utis += [.text]
        }

        if contains(.online_url) {
            utis += [.url]
        }

        return utis
    }

}
