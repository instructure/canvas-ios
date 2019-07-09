//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import TestsFoundation

enum SubmissionComments: String, CaseIterable, ElementWrapper {
    case addCommentButton
    case addMediaButton
    case commentTextView

    private static let className = String(describing: SubmissionComments.self)

    static func attemptCell(submissionID: String, attempt: Int) -> Element {
        return app.find(id: "\(className).attemptCell.submission-\(submissionID)-\(attempt)")
    }

    static func attemptView(attempt: Int) -> Element {
        return app.find(id: "\(className).attemptView.\(attempt)")
    }

    static func audioCell(commentID: String) -> Element {
        return app.find(id: "\(className).audioCell.\(commentID)")
    }

    static func audioCellPlayPauseButton(commentID: String) -> Element {
        return app.find(id: "\(className).audioCell.\(commentID).playPauseButton")
    }

    static func fileView(fileID: String) -> Element {
        return app.find(id: "\(className).fileView.\(fileID)")
    }

    static func textCell(commentID: String) -> Element {
        return app.find(id: "\(className).textCell.\(commentID)")
    }

    static func videoCell(commentID: String) -> Element {
        return app.find(id: "\(className).videoCell.\(commentID)")
    }
}
