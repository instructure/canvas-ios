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

enum SubmissionDetails: String, CaseIterable, ElementWrapper {
    case attemptPicker
    case attemptPickerToggle
    case discussionWebView
    case drawerGripper
    case emptyAssignmentDueBy
    case emptySubmitButton
    case emptyView
    case externalToolButton
    case mediaPlayer
    case onlineQuizWebView
    case onlineTextEntryWebView
    case urlButton
    case urlSubmissionBlurb

    case rubricEmptyView
    case rubricEmptyLabel

    static var drawerCommentsButton: Element {
        return app.find(label: "Comments", type: .button)
    }
    static var drawerFilesButton: Element {
        return app.find(labelContaining: "Files", type: .button)
    }
    static var drawerRubricButton: Element {
        return app.find(label: "Rubric", type: .button)
    }

    static func rubricCellTitle(id: String) -> Element {
        return app.find(id: "RubricCell.title.\(id)")
    }

    static func rubricCellCommentLabel(id: String) -> Element {
        return app.find(id: "RubricCell.comment.\(id)")
    }

    static func rubricCellCommentContainer(id: String) -> Element {
        return app.find(id: "RubricCell.commentContainer.\(id)")
    }

    static func rubricCellDescButton(id: String) -> Element {
        return app.find(id: "RubricCell.descButton.\(id)")
    }

    static func rubricCellRatingTitle(id: String) -> Element {
        return app.find(id: "RubricCell.ratingTitle.\(id)")
    }

    static func rubricCellRatingDesc(id: String) -> Element {
        return app.find(id: "RubricCell.ratingDesc.\(id)")
    }

    static func rubricCellRatingButton(rubricID: String, points: Double) -> Element {
        return app.find(id: "RubricCell.RatingButton.\(rubricID)-\(points)")
    }
}
