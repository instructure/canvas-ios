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

public extension HorizonUI.Colors {
    struct Surface: Sendable, ColorCollection {
        let attention = Color(.attention)
        let attentionSecondary = Color(.attentionSecondary)
        let cardPrimary = Color(.cardPrimary)
        let cardSecondary = Color(.cardSecondary)
        let divider = Color(.divider)
        let error = Color(.surfaceError)
        let institution = Color(.institution)
        let inversePrimary = Color(.inversePrimary)
        let inverseSecondary = Color(.inverseSecondary)
        let overlayGrey = Color(.overlayGrey)
        let overlayWhite = Color(.overlayWhite)
        let pagePrimary = Color(.pagePrimary)
        let pageSecondary = Color(.pageSecondary)
        let pageTertiary = Color(.pageTertiary)
        let surfaceWarning = Color(.surfaceWarning)
        let surfaceSuccess = Color(.surfaceSuccess)

        // TODO: Make it #if DEBUG later
        var allColors: [ColorWithID] = []

        init() {
            allColors = extractColorsWithIDs()
        }
    }
}
