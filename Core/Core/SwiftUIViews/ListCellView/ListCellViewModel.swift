//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import SwiftUI

class ListCellViewModel: ObservableObject {

    let cellStyle: ListCellView.ListCellStyle
    let title: String
    let subtitle: String?
    let selectionState: ListCellView.SelectionState
    let isCollapsed: Bool?
    let selectionDidToggle: (() -> Void)?
    let collapseDidToggle: (() -> Void)?
    let removeItemPressed: (() -> Void)?
    let state: ListCellView.State

    init(cellStyle: ListCellView.ListCellStyle,
         title: String,
         subtitle: String? = nil,
         selectionState: ListCellView.SelectionState = .deselected,
         isCollapsed: Bool? = nil,
         selectionDidToggle: (() -> Void)? = nil,
         collapseDidToggle: (() -> Void)? = nil,
         removeItemPressed: (() -> Void)? = nil,
         progress: Float? = nil,
         state: ListCellView.State) {
        self.cellStyle = cellStyle
        self.title = title
        self.subtitle = subtitle
        self.selectionState = selectionState
        self.isCollapsed = isCollapsed
        self.selectionDidToggle = selectionDidToggle
        self.collapseDidToggle = collapseDidToggle
        self.removeItemPressed = removeItemPressed
        self.state = state
    }

    var backgroundColor: Color {
        switch cellStyle {
        case .mainAccordionHeader:
            return .backgroundLight
        default:
            return .backgroundLightest
        }
    }

    var cellHeight: CGFloat {
        switch cellStyle {
        case .mainAccordionHeader:
            return 72.0
        default:
            return 54.0
        }
    }

    var titleFont: Font {
        switch cellStyle {
        default:
            return .semibold16
        }
    }

    var subtitleFont: Font {
        switch cellStyle {
        default:
            return .regular14
        }
    }

    var accessibilitySelectionText: String {
        switch selectionState {
        case .deselected:
            return NSLocalizedString("Select item", bundle: .core, comment: "")
        case .selected, .partiallySelected:
            return NSLocalizedString("Deselect item", bundle: .core, comment: "")
        }
    }

    var accessibilityAccordionHeaderText: String {
        if isCollapsed == true {
            return NSLocalizedString("Open section", bundle: .core, comment: "")
        }
        return NSLocalizedString("Close section", bundle: .core, comment: "")
    }

    var accessibilityText: String {
        var titleText = title + (subtitle ?? "")
        if case .error(let error) = state, let error = error {
            titleText.append("," + error)
        }
        var selectionText = ""
        if selectionDidToggle != nil {
            switch selectionState {
            case .deselected:
                selectionText = NSLocalizedString("Deselected", bundle: .core, comment: "")
            case .selected:
                selectionText = NSLocalizedString("Selected", bundle: .core, comment: "")
            case .partiallySelected:
                selectionText = NSLocalizedString("Partially selected", bundle: .core, comment: "")
            }
        }
        var collapseText = ""
        if let isCollapsed = isCollapsed {
            switch isCollapsed {
            case true:
                collapseText = NSLocalizedString("Closed section", bundle: .core, comment: "")
            case false:
                collapseText = NSLocalizedString("Open section", bundle: .core, comment: "")
            }
        }

        var progressText = ""
        if case let .loading(progress) = state, let progress = progress, !state.isError {
            if progress == 1 {
                progressText = NSLocalizedString("Download complete", bundle: .core, comment: "")
            } else {
                progressText = NSLocalizedString("Downloading", bundle: .core, comment: "")
            }
        }
        return titleText + "," + selectionText + "," + collapseText + "," + progressText + ","
    }

}
