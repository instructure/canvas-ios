//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import UniformTypeIdentifiers

public enum SubmissionType: String, Codable, CaseIterable {
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
    case wiki_page
    case student_annotation

    public var localizedString: String {
        switch self {
        case .discussion_topic:
            return String(localized: "Discussion Comment", bundle: .core)
        case .external_tool, .basic_lti_launch:
            return String(localized: "External Tool", bundle: .core)
        case .media_recording:
            return String(localized: "Media Recording", bundle: .core)
        case .none:
            return String(localized: "No Submission", bundle: .core)
        case .not_graded:
            return String(localized: "Not Graded", bundle: .core)
        case .online_quiz:
            return String(localized: "Quiz", bundle: .core)
        case .online_text_entry:
            return String(localized: "Text Entry", bundle: .core)
        case .online_upload:
            return String(localized: "File Upload", bundle: .core)
        case .online_url:
            return String(localized: "Website URL", bundle: .core)
        case .on_paper:
            return String(localized: "On Paper", bundle: .core)
        case .wiki_page:
            return String(localized: "Page", bundle: .core)
        case .student_annotation:
            return String(localized: "Student Annotation", bundle: .core)

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
        var types  = [UTType.movie.identifier]

        if contains(.media_recording) && !contains(.online_upload) {
            types.append(UTType.audio.identifier)
        } else {
            types.append(UTType.image.identifier)
        }
        return types
    }

    public func allowedUTIs(allowedExtensions: [String] = []) -> [UTI] {
        var utis: [UTI] = []

        if contains(.online_upload) {
            if allowedExtensions.isEmpty {
                utis += [.any]
            } else {
                utis += UTI.from(extensions: allowedExtensions)
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

    public func isStudioAccepted(
        allowedExtensions: [String]
    ) -> Bool {
        guard self.contains(.online_upload) else {
            return false
        }

        if allowedExtensions.isEmpty {
            return true
        }

        for allowedExtension in allowedExtensions {
            guard let fileType = UTType(filenameExtension: allowedExtension) else {
                continue
            }
            if fileType.conforms(to: .audiovisualContent) {
                return true
            }
        }

        return false
    }
}
