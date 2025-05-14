//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import XCTest

public class LTIHelper: BaseHelper {
    public struct Studio {
        public static var course: DSCourse = DSCourse(id: "3503791", name: "iOS Studio Test Course")
        public static var doneButton: XCUIElement { app.find(id: "screen.dismiss") }
        public static var studioLogoLink: XCUIElement { app.find(label: "Studio Logo", type: .link) }
        public static var myLibraryLabel: XCUIElement { app.find(label: "My Library", type: .staticText) }

        public struct Embedded {
            public static var testVideoTitle: XCUIElement { app.find(label: "RPReplay_Final1686153416") }
            public static var playButton: XCUIElement { app.find(label: "Play", type: .button) }
        }
    }
}
