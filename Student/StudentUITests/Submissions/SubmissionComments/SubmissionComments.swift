//
// Copyright (C) 2019-present Instructure, Inc.
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

struct SubmissionComments: RawRepresentable, Element {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let addCommentButton = SubmissionComments(rawValue: "addCommentButton")
    static let addMediaButton = SubmissionComments(rawValue: "addMediaButton")
    static let commentTextView = SubmissionComments(rawValue: "commentTextView")

    static func attemptCell(submissionID: String, attempt: Int) -> SubmissionComments {
        return SubmissionComments(rawValue: "attemptCell.submission-\(submissionID)-\(attempt)")
    }

    static func attemptView(attempt: Int) -> SubmissionComments {
        return SubmissionComments(rawValue: "attemptView.\(attempt)")
    }

    static func audioCell(commentID: String) -> SubmissionComments {
        return SubmissionComments(rawValue: "audioCell.\(commentID)")
    }

    static func audioCellPlayPauseButton(commentID: String) -> SubmissionComments {
        return SubmissionComments(rawValue: "audioCell.\(commentID).playPauseButton")
    }

    static func fileView(fileID: String) -> SubmissionComments {
        return SubmissionComments(rawValue: "fileView.\(fileID)")
    }

    static func textCell(commentID: String) -> SubmissionComments {
        return SubmissionComments(rawValue: "textCell.\(commentID)")
    }

    static func videoCell(commentID: String) -> SubmissionComments {
        return SubmissionComments(rawValue: "videoCell.\(commentID)")
    }
}
