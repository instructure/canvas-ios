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
