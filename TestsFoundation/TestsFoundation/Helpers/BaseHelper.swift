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

import Foundation

open class BaseHelper {
    public static let seeder = DataSeeder()
    public static var user: UITestUser {.dataSeedAdmin}
    public static var backButton: Element { app.find(label: "Back", type: .button) }
    public static var nextButton: Element { app.find(id: "nextButton", type: .button) }
    public static func pullToRefresh() {
        let window = app.find(type: .window)
        window.relativeCoordinate(x: 0.5, y: 0.2)
            .press(forDuration: 0.05, thenDragTo: window.relativeCoordinate(x: 0.5, y: 1.0))
    }
}
