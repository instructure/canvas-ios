//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

extension Font.Weight {

    /// Initializes a `Font.Weight` from a CSS numeric weight string (e.g. `"300"`, `"700"`).
    /// Returns `nil` for unrecognized values.
    init?(cssNumeric: String) {
        switch cssNumeric {
        case "100": self = .ultraLight
        case "200": self = .thin
        case "300": self = .light
        case "400": self = .regular
        case "500": self = .medium
        case "600": self = .semibold
        case "700": self = .bold
        case "800": self = .heavy
        case "900": self = .black
        default: return nil
        }
    }
}
