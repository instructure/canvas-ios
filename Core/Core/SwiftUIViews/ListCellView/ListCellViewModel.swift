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
    let error: String?
    let selectionState: ListCellView.SelectionState
    let isCollapsed: Bool?
    let selectionDidToggle: (() -> Void)?
    let collapseDidToggle: (() -> Void)?
    let removeItemPressed: (() -> Void)?
    let progress: Float?

    init(cellStyle: ListCellView.ListCellStyle,
         title: String,
         subtitle: String? = nil,
         selectionState: ListCellView.SelectionState = .deselected,
         isCollapsed: Bool? = nil,
         selectionDidToggle: (() -> Void)? = nil,
         collapseDidToggle: (() -> Void)? = nil,
         removeItemPressed: (() -> Void)? = nil,
         progress: Float? = nil,
         error: String? = nil) {
        self.cellStyle = cellStyle
        self.title = title
        self.subtitle = subtitle
        self.selectionState = selectionState
        self.isCollapsed = isCollapsed
        self.selectionDidToggle = selectionDidToggle
        self.collapseDidToggle = collapseDidToggle
        self.removeItemPressed = removeItemPressed
        self.progress = progress
        self.error = error
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

    var accessibilitySelectionText: Text {
        switch selectionState {
        case .deselected:
            return Text("Select item", bundle: .core)
        case .selected, .partiallySelected:
            return Text("Deselect item", bundle: .core)
        }
    }

    var accessibilityAccordionHeaderText: Text {
        if isCollapsed == true {
            return Text("Open section", bundle: .core)
        }
        return Text("Close section", bundle: .core)
    }

    var accessibilityText: String {
        var titleText = title + (subtitle ?? "")
        if let error = error {
            titleText.append("," + error)
        }
        var selectionText = ""
        if selectionDidToggle != nil {
            switch selectionState {
            case .deselected:
                selectionText = String(localized: "Deselected", bundle: .core)
            case .selected:
                selectionText = String(localized: "Selected", bundle: .core)
            case .partiallySelected:
                selectionText = String(localized: "Partially selected", bundle: .core)
            }
        }
        var collapseText = ""
        if let isCollapsed = isCollapsed {
            switch isCollapsed {
            case true:
                collapseText = String(localized: "Closed section", bundle: .core)
            case false:
                collapseText = String(localized: "Open section", bundle: .core)
            }
        }

        var progressText = ""
        if let progress = progress, error == nil {
            if progress == 1 {
                progressText = String(localized: "Download complete", bundle: .core)
            } else {
                progressText = String(localized: "Downloading", bundle: .core)
            }
        }

        return titleText + "," + selectionText + "," + collapseText + "," + progressText + ","
    }

}
