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

import Foundation

public enum K5NavigationBar: ElementWrapper {

    public static var homeroom: Element {
        app.find(label: "Homeroom")
    }

    public static var schedule: Element {
        app.find(label: "Schedule")
    }

    public static var grades: Element {
        app.find(label: "Grades")
    }

    public static var resources: Element {
        app.find(label: "Resources")
    }
}

public enum K5Dashboard: ElementWrapper {

    public static var accountNotification: Element {
        app.find(id: "AccountNotification.2.toggleButton")
    }

    public static var accountNotificationString: Element {
        app.find(label: "FYI, Tap to view announcement", type: XCUIElement.ElementType.button)
    }
}
