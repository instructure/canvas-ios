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

public enum K5CourseNavigation: ElementWrapper {

    public static var homeTab: Element {
        app.find(label: "Home")
    }

    public static var scheduleTab: Element {
        app.find(label: "Schedule")
    }

    public static var modulesTab: Element {
        app.find(label: "Modules")
    }

    public static var gradesTab: Element {
        app.find(label: "Grades")
    }
}

public enum K5CourseModulesPage: ElementWrapper {

    public static var emptyPage: Element {
        app.find(label: "Your modules will appear here after they're assembled.")
    }
}

public enum K5CourseHomePage: ElementWrapper {

    public static var emptyPage: Element {
        app.find(label: "This is where you'll land when your home is complete.")
    }
}
