//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public enum QuizDetails: String, ElementWrapper {
    case takeButton

    public static var submitButton: Element {
        return app.buttons.matching(label: "Submit").firstElement
    }

    public static func text(string: String) -> Element {
        return app.find(labelContaining: string)
    }

    public static var previewQuiz: Element {
        return app.find(label: "Preview Quiz")
    }

    public static var launchExternalToolButton: Element {
        return app.find(label: "Launch External Tool")
    }
}
