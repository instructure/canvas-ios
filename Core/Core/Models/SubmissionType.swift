//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

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
