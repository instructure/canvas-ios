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

import SwiftUI

extension HorizonUI.Colors {
    struct Primitives {
        // TODO: Add other variants

        let blue12 = Color(hexString: "#E0EBF5")!
        let blue45 = Color(hexString: "#2B7ABC")!
        let blue57 = Color(hexString: "#0E68B3")!

        // TODO: Make it #if DEBUG later
        let allColors: [ColorWithID]

        init() {
            self.allColors = [
                ColorWithID("blue12", blue12),
                ColorWithID("blue45", blue45),
                ColorWithID("blue57", blue57)
            ]
        }
    }
}
