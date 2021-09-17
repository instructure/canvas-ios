//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public enum K5Schedule: ElementWrapper {
    case today

    public static var previousWeekButton: Element {
        app.find(label: "Previous Week", type: .button)
    }

    public static var nextWeekButton: Element {
        app.find(label: "Next Week", type: .button)
    }

    public static var todayHeader: Element {
        app.find(labelContaining: "Today", type: .staticText)
    }

    public static var todayButton: Element {
        app.find(label: "Today", type: .button)
    }
}
