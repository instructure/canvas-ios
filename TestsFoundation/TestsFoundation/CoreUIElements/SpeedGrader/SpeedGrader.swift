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
import XCTest

public enum SpeedGrader: String, ElementWrapper {
    case doneButton, drawerGripper, gradeButton, postPolicyButton, toolPicker, userButton

    public enum DrawerState {
        case min, mid, max
        var label: String {
            switch self {
            case .min: return "Open Drawer half screen"
            case .mid: return "Open Drawer full screen"
            case .max: return "Close Drawer"
            }
        }
    }
    public static func setDrawerState(_ state: DrawerState) {
        drawerGripper.tapUntil { drawerGripper.label() == state.label }
    }

    public enum Segment {
        public static var grades: Element { withLabel(label: "Grades") }
        public static var comments: Element { withLabel(label: "Comments") }
        public static var files: Element { withLabel(label: "Files") }

        public static func withLabel(label: String) -> Element {
            let segmentControl = SpeedGrader.toolPicker.waitToExist()
            return segmentControl.rawElement.find(labelContaining: label)
        }
    }

    public enum Rubric {
        public static func addCommentButton(id: String) -> Element {
            app.find(id: "SpeedGrader.Rubric.\(id).addCommentButton")
        }
    }
}
